//
//  AdsViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 8/28/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "AdsViewController.h"
#import "Global.h"

@interface AdsViewController ()

@end

@implementation AdsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FAKFontAwesome *iconClose = [FAKFontAwesome timesCircleIconWithSize:CLOSE_BUTTON_SIZE];
    [iconClose addAttribute:NSForegroundColorAttributeName value:NAVI_COLOR];
    UIImage *imgClose = [iconClose imageWithSize:CGSizeMake(CLOSE_BUTTON_SIZE, CLOSE_BUTTON_SIZE)];
    [self.m_btnClose setImage:imgClose forState:UIControlStateNormal];
    
    self.m_imageView.layer.cornerRadius = CLOSE_BUTTON_SIZE / 2.f;
    self.m_imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_imageView.layer.borderWidth = 5.f;
    self.m_imageView.clipsToBounds = YES;

    self.m_btnClose.layer.cornerRadius = CLOSE_BUTTON_SIZE / 2.f;
    self.m_btnClose.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_btnClose.layer.borderWidth = 2.f;
    self.m_btnClose.clipsToBounds = YES;

    [self loadAds];
    
    self.m_btnClose.hidden = YES;
    self.m_imageView.hidden = YES;
    self.m_btnAction.hidden = YES;
    self.m_activity.hidden = NO;
}

- (void) showLoadingView
{
    MBProgressHUD *progressHUB = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUB];
    progressHUB.tag = 100;
    
    [progressHUB show:YES];
    
}

- (void) hideLoadingView
{
    MBProgressHUD* progressHUB = (MBProgressHUD *)[self.view viewWithTag:100];
    if (progressHUB)
    {
        [progressHUB hide:YES];
        [progressHUB removeFromSuperview];
        progressHUB = nil;
    }
}

- (void) loadAds
{
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"ads"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"GET"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *receivedData = [request responseString];
    NSDictionary* dictResponse = [receivedData JSONValue];
    if (dictResponse == nil)
    {
        [self actionClose:self.m_btnClose];
        return;
    }
    
    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        dictAdsInfo = [dictResponse valueForKey:@"ads"];
        
        NSString* strPhoto = [NSString stringWithFormat:@"%@%@", ADS_IMAGE_URL, [dictAdsInfo valueForKey:@"image"]];
        
        if ([strPhoto isKindOfClass:[NSNull class]]) return;
        if (strPhoto == nil || [strPhoto isEqualToString:@""]) return;
        
        NSString* strFileName = [[Utils sharedObject] getImageNameFromLink:strPhoto];
        UIImage *image = [[Utils sharedObject] readImageFromLocal:strFileName];
        if (image)
        {
            self.m_btnClose.hidden = NO;
            self.m_activity.hidden = YES;
            
            self.m_imageView.hidden = NO;
            self.m_btnAction.hidden = NO;

            self.m_imageView.image = image;
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
                NSURL* urlWithString = [NSURL URLWithString:strPhoto];
                __block NSData* imageData = [NSData dataWithContentsOfURL:urlWithString];
                dispatch_async(dispatch_get_main_queue(), ^{ // 2
                    UIImage* downloadedImage = [UIImage imageWithData:imageData];
                    self.m_imageView.image = downloadedImage;
                    
                    [[Utils sharedObject] saveImageToLocal:downloadedImage withName:strFileName];
                    
                    self.m_btnClose.hidden = NO;
                    self.view.backgroundColor = [UIColor clearColor];
                    self.m_activity.hidden = YES;
                    
                    self.m_imageView.hidden = NO;
                    self.m_btnAction.hidden = NO;

                    imageData = nil;
                    downloadedImage = nil;
                });
            });
        }

    }
   
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self actionClose:self.m_btnClose];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionClose:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];

}
- (IBAction)actionGotoSite:(id)sender {
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[dictAdsInfo valueForKey:@"promotion_link"]]];
    
};

@end
