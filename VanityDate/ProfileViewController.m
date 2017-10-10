//
//  ProfileViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ProfileViewController.h"
#import "Global.h"
#import "UploadPictureViewController.h"
#import "ProfileSettingViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
@synthesize m_arrayPhotos;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"PROFILE";

    FAKFontAwesome *naviRightIcon = [FAKFontAwesome cogIconWithSize:NAVI_ICON_SIZE];
    [naviRightIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imageRightButton = [naviRightIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imageRightButton style:UIBarButtonItemStylePlain target:self action:@selector(updateProfile)];

    m_arrayPhotos = [[NSMutableArray alloc] init];
    arrayPhotoViewsAsGrid = [[NSMutableArray alloc] init];
    arrayPhotoViewsAsList = [[NSMutableArray alloc] init];
    
    self.m_userImageView.layer.cornerRadius = self.m_userImageView.frame.size.height / 2;
    self.m_userImageView.layer.borderWidth = 2.f;
    self.m_userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_userImageView.clipsToBounds = YES;
    
    self.m_scrollViewGrid.hidden = NO;
    self.m_scrollViewList.hidden = YES;
    self.m_mapView.hidden = YES;
    
    bUpdatedImage = false;
    avatarImage = nil;
    
    self.m_mapView.delegate = self;
    
    [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, g_Delegate.m_strCurUserProfileImage] imageView:self.m_userImageView];
}

- (void) viewDidAppear:(BOOL)animated
{
    if (bUpdatedImage)
        [self updateProfileImage];
    else
        [self getProfile];
}

- (void) deletePhoto
{
    nRequestMode = DELETE_PHOTO_REQUEST;
    
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/delete_photo"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:[[m_arrayPhotos objectAtIndex:nSelectedPhotoIdx] valueForKey:@"id"] forKey:@"photo_id"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
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
    
    [request setPostValue:[g_Delegate.m_curUserInfo valueForKey:@"id"] forKey:@"sel_id"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (void) updateProfile
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ProfileSettingViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"profilesettingview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
    
}

-(MapPinAnnotation *)showClusterPoint:(CLLocationCoordinate2D)coords withPos:(NSString *)place
{
    float  zoomLevel = 0.5;
    MKCoordinateRegion region = MKCoordinateRegionMake (coords, MKCoordinateSpanMake (zoomLevel, zoomLevel));
    [self.m_mapView setRegion: [self.m_mapView regionThatFits: region] animated: YES];
    
    MapPinAnnotation* pinAnnotation =
    [[MapPinAnnotation alloc] initWithCoordinates:coords
                                        placeName:@"My current location"
                                      description:nil];
    [self.m_mapView addAnnotation:pinAnnotation];
    
    return pinAnnotation;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString* myIdentifier = @"profilepin";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:myIdentifier];
    
    if (!pinView)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myIdentifier];
        pinView.pinColor = MKPinAnnotationColorRed;
//        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }
  
    pinView.image = [UIImage imageNamed:@"map_pin.png"];
    pinView.annotation = annotation;

    return pinView;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tapGesture:(UITapGestureRecognizer *) sender
{
    NSLog(@"tapped photo");
    UIImageView* catImageView = (UIImageView *)(sender.view);
}

- (void) loadPhotosAsGrid
{
    CGFloat viewWidth = CGRectGetWidth(self.m_scrollViewGrid.frame);
    
    for (int nIdx = 0; nIdx < arrayPhotoViewsAsGrid.count; nIdx++)
    {
        UIImageView* subView = (UIImageView *)[arrayPhotoViewsAsGrid objectAtIndex:nIdx];
        subView.hidden = YES;
        [subView removeFromSuperview];
    }
    
    [arrayPhotoViewsAsGrid removeAllObjects];
    
    float fItemSizeWidth = viewWidth / 3.f;
    float fItemSizeHeight = fItemSizeWidth;
    
    int nCatItemIdx = -1;
    int nRowIdx = 0;
    
    for (int nIdx = 0; nIdx < m_arrayPhotos.count; nIdx++)
    {
        NSDictionary* dictPhotoInfo = [m_arrayPhotos objectAtIndex:nIdx];
        
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
        catSubView.center = CGPointMake(fItemSizeWidth / 2.f * (nCatItemIdx % 3 * 2 + 1),fItemSizeHeight / 2.f * (nRowIdx * 2 + 1));
        catSubView.userInteractionEnabled = true;
        UITapGestureRecognizer *tapGestureForImage = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
        tapGestureForImage.numberOfTapsRequired = 1;
        catSubView.tag = 120 + nIdx;
        [tapGestureForImage setDelegate:self];
        [catSubView addGestureRecognizer:tapGestureForImage];
        
        [self.m_scrollViewGrid addSubview:catSubView];
        [arrayPhotoViewsAsGrid addObject:catSubView];
        
        [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@",RESOURCE_URL, [dictPhotoInfo valueForKey:@"photo_url"]] imageView:catSubView];
    }
    
    float fScrollHeight = fItemSizeHeight / 2.f * (nRowIdx * 2 + 1) + fItemSizeHeight / 2.f;
    
    self.m_scrollViewGrid.contentSize = CGSizeMake(viewWidth, fScrollHeight);

}

- (void) loadPhotoAsList
{
    CGFloat viewWidth = CGRectGetWidth(self.m_scrollViewList.frame);
    
    for (int nIdx = 0; nIdx < arrayPhotoViewsAsList.count; nIdx++)
    {
        SelfieCustomView* subView = (SelfieCustomView *)[arrayPhotoViewsAsList objectAtIndex:nIdx];
        subView.hidden = YES;
        [subView removeFromSuperview];
    }
    
    [arrayPhotoViewsAsList removeAllObjects];
    
    float fItemSizeWidth = viewWidth;
    float fItemSizeHeight = fItemSizeWidth;
    
    float fScrollHeight = 0.f;
    
    for (int nIdx = 0; nIdx < m_arrayPhotos.count; nIdx++)
    {
        NSDictionary* dictPhotoInfo = [m_arrayPhotos objectAtIndex:nIdx];

        SelfieCustomView* catSubView = [[[NSBundle mainBundle] loadNibNamed:@"SelfieCustomView" owner:self options:nil] objectAtIndex:0];
        catSubView.frame = CGRectMake(0, 0, fItemSizeWidth, fItemSizeHeight);
        
        fScrollHeight += 10 + fItemSizeHeight / 2;
        catSubView.center = CGPointMake(viewWidth / 2.f, fScrollHeight);
        catSubView.userInteractionEnabled = true;
        
        catSubView.m_nIdx = nIdx;
        catSubView.delegate = self;
        catSubView.m_bMode = true;
        [catSubView updateUI];
        catSubView.m_lblTime.text = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictPhotoInfo valueForKey:@"created"] longLongValue]] withFormat:@"MMM dd, yyyy"];

        fScrollHeight += fItemSizeHeight / 2;
        [self.m_scrollViewList addSubview:catSubView];
        [arrayPhotoViewsAsList addObject:catSubView];

        [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@",RESOURCE_URL, g_Delegate.m_strCurUserProfileImage] imageView:catSubView.m_userImageView];

        [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@",RESOURCE_URL, [dictPhotoInfo valueForKey:@"photo_url"]] imageView:catSubView.m_postImageView];
    }
    
    fScrollHeight += 10;
    
    self.m_scrollViewList.contentSize = CGSizeMake(viewWidth, fScrollHeight);

}

- (void) actionDelete:(SelfieCustomView *)selfieView index:(int)nSelectedIdx
{
    NSLog(@"delete");
    nSelectedPhotoIdx = nSelectedIdx;
    
    [self deletePhoto];
}

- (void) actionReport:(SelfieCustomView *)selfieView index:(int)nSelectedIdx
{
    NSLog(@"report");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionEditImage:(id)sender {
    [self openCamera];
}

- (void) openCamera {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:type])
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            type = UIImagePickerControllerSourceTypeCamera;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [[picker navigationBar] setBarTintColor:MAIN_COLOR];
        [[picker navigationBar] setTintColor:[UIColor whiteColor]];
        [picker navigationBar].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:18.0f], UITextAttributeFont,
                                                      [UIColor whiteColor], UITextAttributeTextColor,
                                                      [UIColor grayColor], UITextAttributeTextShadowColor,
                                                      [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                      nil];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:picker animated:YES completion:nil];
        });
    }
}

- (void) chooseFromLibaray {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:type])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [[picker navigationBar] setBarTintColor:MAIN_COLOR];
        [[picker navigationBar] setTintColor:[UIColor whiteColor]];
        [picker navigationBar].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:18.0f], UITextAttributeFont,
                                                      [UIColor whiteColor], UITextAttributeTextColor,
                                                      [UIColor grayColor], UITextAttributeTextShadowColor,
                                                      [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                      nil];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:picker animated:YES completion:nil];
        });
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* selectedImage = [[info valueForKey:UIImagePickerControllerEditedImage] fixOrientation];

    bUpdatedImage = true;
    avatarImage = selectedImage;
    
    self.m_userImageView.image = selectedImage;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void) updateProfileImage
{
    if (!bUpdatedImage || !avatarImage)
        return;
    
    nRequestMode = UPDATE_AVATAR_REQUEST;
    
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/update_avatar"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];

    NSData* imageData = UIImageJPEGRepresentation(avatarImage, 0.7f);
    [request addData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"photo"];
    
    [request setPostFormat:ASIMultipartFormDataPostFormat];
    
    [request startAsynchronous];

}

- (IBAction)actionViewGrid:(id)sender {
    self.m_scrollViewGrid.hidden = NO;
    self.m_scrollViewList.hidden = YES;
    self.m_mapView.hidden = YES;
}

- (IBAction)actionLocation:(id)sender {
    self.m_scrollViewGrid.hidden = YES;
    self.m_scrollViewList.hidden = YES;
    self.m_mapView.hidden = NO;
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([g_Delegate.m_strLatitude floatValue], [g_Delegate.m_strLongitude floatValue]);
    
    [self showClusterPoint:coordinate withPos:@"location"];
}

- (IBAction)actionSelfie:(id)sender {
    bUpdatedImage = false;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UploadPictureViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"uploadview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];

}

- (IBAction)actionViewList:(id)sender {
    self.m_scrollViewGrid.hidden = YES;
    self.m_scrollViewList.hidden = NO;
    self.m_mapView.hidden = YES;
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
    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        if (nRequestMode == UPDATE_AVATAR_REQUEST)
        {
            bUpdatedImage = false;
            avatarImage = nil;
            
            [g_Delegate AlertSuccess:@"Updated your photo successfully."];
        }
        
        if (nRequestMode == GET_PROFILE_REQUEST)
        {
            g_Delegate.m_curUserInfo = [[dictResponse valueForKey:@"user_info"] lastObject];
            
            [m_arrayPhotos removeAllObjects];
            NSArray* arrayTemp = [dictResponse valueForKey:@"photos"];
            for (int nIdx = 0; nIdx < arrayTemp.count; nIdx++)
            {
                NSDictionary* dictInfo = [arrayTemp objectAtIndex:nIdx];
                if ([[dictInfo valueForKey:@"is_avatar"] integerValue] == 1)
                    continue;
                
                [m_arrayPhotos addObject:dictInfo];
            }
            
//            m_arrayPhotos = [dictResponse valueForKey:@"photos"];
            
            [self loadPhotosAsGrid];
            [self loadPhotoAsList];
        }
        
        if (nRequestMode == DELETE_PHOTO_REQUEST)
        {
            [g_Delegate AlertSuccess:@"Deleted photo successfully."];
            
            [m_arrayPhotos removeObjectAtIndex:nSelectedPhotoIdx];

            [self loadPhotosAsGrid];
            [self loadPhotoAsList];
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

@end
