//
//  FriendProfileViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "FriendProfileViewController.h"
#import "Global.h"
#import "HomeViewController.h"
#import "MessageController.h"

@interface FriendProfileViewController ()

@end

@implementation FriendProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.title = [NSString stringWithFormat:@"%@'s Profile", self.m_strUserName];
    self.navigationItem.title = @"PROFILE";
    
    self.m_bgImageView.image = [[Utils sharedObject] rn_boxblurImageWithBlur:BLUR_DEGREE exclusionPath:nil image:[UIImage imageNamed:@"bg.png"]];

    [self updateUI];
    
    self.m_lblUserName.text = self.m_strUserName;
    
    arrayPhotos = [[NSMutableArray alloc] init];
    arrayPhotoViews = [[NSMutableArray alloc] init];
    
    bClickedPopUp = false;
    self.m_viewPopup.hidden = YES;

    self.m_btnReport.layer.cornerRadius = self.m_btnReport.frame.size.height / 2.f;
    self.m_btnReport.clipsToBounds = YES;
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    [self.m_btnActionBack setImage:imgBack forState:UIControlStateNormal];
    
    [self getProfile];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;

    [g_Delegate.m_curHomeViewCon hideMenuTabView];

    [self performSelector:@selector(updateUI) withObject:nil afterDelay:INDICATOR_ANIMATION + 0.1f];
}

- (void) updateUI
{
    if (self.m_userImageView.frame.size.width > self.m_userImageView.frame.size.height)
        self.m_userImageView.frame = CGRectMake(self.m_userImageView.frame.origin.x, self.m_userImageView.frame.origin.y, self.m_userImageView.frame.size.height, self.m_userImageView.frame.size.height);
    else
        self.m_userImageView.frame = CGRectMake(self.m_userImageView.frame.origin.x, self.m_userImageView.frame.origin.y, self.m_userImageView.frame.size.width, self.m_userImageView.frame.size.width);
    
    self.m_userImageView.layer.cornerRadius = self.m_userImageView.frame.size.height / 2.f;
    self.m_userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_userImageView.layer.borderWidth = 2.f;
    self.m_userImageView.clipsToBounds = YES;
    self.m_userImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE];
    [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, self.m_strUserPhotoUrl] imageView:self.m_userImageView];
    
    [[Utils sharedObject] makeBlurImage:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, self.m_strUserPhotoUrl] imageView:self.m_bgImageView];
    
    self.m_userImageView.center = CGPointMake(self.m_viewUserInfo.frame.size.width / 2, self.m_userImageView.center.y);
    
    [self.m_lblLocation sizeToFit];
    float fTemp = (self.m_viewUserInfo.frame.size.width - self.m_imageLocationMark.frame.size.width - 10.f - self.m_lblLocation.frame.size.width) / 2.f;
    self.m_lblLocation.center = CGPointMake(fTemp + self.m_imageLocationMark.frame.size.width + 10.f + self.m_lblLocation.frame.size.width / 2, self.m_imageLocationMark.center.y);
    self.m_imageLocationMark.center = CGPointMake(fTemp + self.m_imageLocationMark.frame.size.width / 2, self.m_imageLocationMark.center.y);
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void) backToMainView
{
    NSArray* viewControllers = [self.navigationController viewControllers];
    
    UIViewController *previousViewController = [viewControllers objectAtIndex:([viewControllers indexOfObject:self]-1)];
    if(![previousViewController isKindOfClass:[MessageController class]])
        [g_Delegate.m_curHomeViewCon showMenuTabView];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    bClickedPopUp = false;
    self.m_viewPopup.hidden = YES;
}

- (void) actionChooseViewMode
{
    if (bClickedPopUp)
    {
        bClickedPopUp = false;
        self.m_viewPopup.hidden = YES;
    }
    else
    {
        bClickedPopUp = true;
        self.m_viewPopup.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getProfile
{
    nRequestMode = GET_PROFILE_REQUEST;
    
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/get_profile"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:self.m_strUserId forKey:@"sel_id"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (void) reportPhoto
{
    nRequestMode = REPORT_PHOTO_REQUEST;
    
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/report_photo"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:[[arrayPhotos objectAtIndex:nSelectedPhotoIdx] valueForKey:@"id"] forKey:@"photo_id"];
    [request setPostValue:self.m_strUserId forKey:@"sel_id"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionViewListMode:(id)sender {
    bClickedPopUp = false;
    self.m_viewPopup.hidden = YES;
    
    [self loadPhotoAsList];
}

- (IBAction)actionViewGridMode:(id)sender {
    bClickedPopUp = false;
    self.m_viewPopup.hidden = YES;
    
    [self loadPhotosAsGrid];
}

- (void) tapGesture:(UITapGestureRecognizer *) sender
{
    NSLog(@"tapped photo");
    UIImageView* catImageView = (UIImageView *)(sender.view);
}

- (void) loadPhotosAsGrid
{
    CGFloat viewWidth = CGRectGetWidth(self.m_scrollView.frame);
    
    for (int nIdx = 0; nIdx < arrayPhotoViews.count; nIdx++)
    {
        UIImageView* subView = (UIImageView *)[arrayPhotoViews objectAtIndex:nIdx];
        subView.hidden = YES;
        [subView removeFromSuperview];
    }
    
    [arrayPhotoViews removeAllObjects];
    
    float fItemSizeWidth = viewWidth / 3.f;
    float fItemSizeHeight = fItemSizeWidth;
    
    int nCatItemIdx = -1;
    int nRowIdx = 0;
    
    for (int nIdx = 0; nIdx < arrayPhotos.count; nIdx++)
    {
        NSDictionary* dictPhotoInfo = [arrayPhotos objectAtIndex:nIdx];
        
        nCatItemIdx++;
        nRowIdx = nCatItemIdx / 3;
        
        UIImageView* catSubView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fItemSizeWidth, fItemSizeHeight)];
        catSubView.image = [UIImage imageNamed:DEFAULT_SELFIE_IMAGE];
        catSubView.contentMode = UIViewContentModeScaleAspectFill;
        /*
         catSubView.layer.borderColor = OTHER_BG_COLOR.CGColor;
         catSubView.layer.borderWidth = 2.f;
         catSubView.layer.cornerRadius = 5.f;
         */
        catSubView.clipsToBounds = YES;
        catSubView.center = CGPointMake(fItemSizeWidth / 2.f * (nCatItemIdx % 3 * 2 + 1),fItemSizeHeight / 2.f * (nRowIdx * 2 + 1) + 10.f);
        catSubView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapGestureForImage = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
        tapGestureForImage.numberOfTapsRequired = 1;
        catSubView.tag = 120 + nIdx;
        [tapGestureForImage setDelegate:self];
        [catSubView addGestureRecognizer:tapGestureForImage];
        
        [self.m_scrollView addSubview:catSubView];
        [arrayPhotoViews addObject:catSubView];
        
        [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@",RESOURCE_URL, [dictPhotoInfo valueForKey:@"photo_url"]] imageView:catSubView];
    }
    
    float fScrollHeight = fItemSizeHeight / 2.f * (nRowIdx * 2 + 1) + fItemSizeHeight / 2.f + 20.f;
    
    self.m_scrollView.contentSize = CGSizeMake(viewWidth, fScrollHeight);
    
}

- (void) loadPhotoAsList
{
    CGFloat viewWidth = CGRectGetWidth(self.m_scrollView.frame);
    
    for (int nIdx = 0; nIdx < arrayPhotoViews.count; nIdx++)
    {
        SelfieCustomView* subView = (SelfieCustomView *)[arrayPhotoViews objectAtIndex:nIdx];
        subView.hidden = YES;
        [subView removeFromSuperview];
    }
    
    [arrayPhotoViews removeAllObjects];
    
    float fItemSizeWidth = viewWidth;
    float fItemSizeHeight = fItemSizeWidth;
    
    float fScrollHeight = 0.f;
    
    for (int nIdx = 0; nIdx < arrayPhotos.count; nIdx++)
    {
        NSDictionary* dictPhotoInfo = [arrayPhotos objectAtIndex:nIdx];
        
        SelfieCustomView* catSubView = [[[NSBundle mainBundle] loadNibNamed:@"SelfieCustomView" owner:self options:nil] objectAtIndex:0];
        catSubView.frame = CGRectMake(0, 0, fItemSizeWidth, fItemSizeHeight);
        
        fScrollHeight += 10 + fItemSizeHeight / 2;
        catSubView.center = CGPointMake(viewWidth / 2.f, fScrollHeight);
        catSubView.userInteractionEnabled = true;
        
        catSubView.m_nIdx = nIdx;
        catSubView.delegate = self;
        catSubView.m_bMode = false;
        [catSubView updateUI];
        catSubView.m_lblTime.text = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictPhotoInfo valueForKey:@"created"] longLongValue]] withFormat:@"MMM dd, yyyy"];
        
        fScrollHeight += fItemSizeHeight / 2;
        [self.m_scrollView addSubview:catSubView];
        [arrayPhotoViews addObject:catSubView];
        
        [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@",RESOURCE_URL, self.m_strUserPhotoUrl] imageView:catSubView.m_userImageView];
        
        [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@",RESOURCE_URL, [dictPhotoInfo valueForKey:@"photo_url"]] imageView:catSubView.m_postImageView];
    }
    
    fScrollHeight += 10;
    
    self.m_scrollView.contentSize = CGSizeMake(viewWidth, fScrollHeight);
    
}

- (void) actionDelete:(SelfieCustomView *)selfieView index:(int)nSelectedIdx
{
    NSLog(@"delete");
}

- (void) actionReport:(SelfieCustomView *)selfieView index:(int)nSelectedIdx
{
    NSLog(@"report");

    nSelectedPhotoIdx = nSelectedIdx;
    
    [self reportPhoto];
}

- (void) showLoadingView
{
    MBProgressHUD *progressHUB = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:progressHUB];
    progressHUB.tag = 100;
    
    [progressHUB show:YES];
    
}

- (void) hideLoadingView
{
    MBProgressHUD* progressHUB = (MBProgressHUD *)[self.navigationController.view viewWithTag:100];
    if (progressHUB)
    {
        [progressHUB hide:YES];
        [progressHUB removeFromSuperview];
        progressHUB = nil;
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    
    NSString *receivedData = [request responseString];
    NSDictionary* dictResponse = [receivedData JSONValue];
    if (dictResponse == nil)
    {
        [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
        return;
    }
    
    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        if (nRequestMode == GET_PROFILE_REQUEST)
        {
            [arrayPhotos removeAllObjects];
            
            dictUserInfo = [[dictResponse valueForKey:@"user_info"] lastObject];

            self.m_lblUserName.text = [dictUserInfo valueForKey:@"username"];

            NSArray* arrayTemp = [dictResponse valueForKey:@"photos"];
            for (int nIdx = 0; nIdx < arrayTemp.count; nIdx++)
            {
                NSDictionary* dictInfo = [arrayTemp objectAtIndex:nIdx];
                if ([[dictInfo valueForKey:@"is_avatar"] integerValue] == 1)
                    continue;
                
                [arrayPhotos addObject:dictInfo];
            }

//            arrayPhotos = [dictResponse valueForKey:@"photos"];
         
            [self loadPhotoAsList];
        }
        
        if (nRequestMode == REPORT_USER_REQUEST)
        {
            [g_Delegate AlertSuccess:@"Reported successfully. Thank you!"];
        }
        
        if (nRequestMode == REPORT_PHOTO_REQUEST)
        {
            [g_Delegate AlertSuccess:@"Reported successfully. Thank you!"];
        }
    }
    else
    {
        //
        [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

- (IBAction)actionBack:(id)sender {
    [self backToMainView];
}

- (IBAction)actionViewModePhotos:(id)sender
{
    [self actionChooseViewMode];
}

- (IBAction)actionReport:(id)sender {
    nRequestMode = REPORT_USER_REQUEST;
    
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/report_user"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:self.m_strUserId forKey:@"sel_id"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

@end
