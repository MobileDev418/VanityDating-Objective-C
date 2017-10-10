//
//  ProfileSettingViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ProfileSettingViewController.h"
#import "Global.h"
#import "ProfileEditViewController.h"
#import "HomeViewController.h"
#import "PrivacyViewController.h"

@interface ProfileSettingViewController ()

@end

@implementation ProfileSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Setting";
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgButton = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgButton style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionUpdateProfile:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ProfileEditViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"profileeditview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (IBAction)actionDeleteAccountg:(id)sender {
    [self showLoadingView];
    
    nRequestMode = DELETE_ACCOUNT_REQUEST;

    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/delete_account"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setRequestMethod:@"POST"];

    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (IBAction)actionDeactiveAccount:(id)sender {
    [self showLoadingView];
    
    nRequestMode = DEACTIVATE_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/deactivate"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setRequestMethod:@"POST"];

    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (IBAction)actionSignOut:(id)sender {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Are you sure to log out?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alertView.tag = 99;
    [alertView show];
}

- (IBAction)actionTerms:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PrivacyViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"termsview"];
    viewCon.m_bViewMode = false;
    UINavigationController *naviCon = [[UINavigationController alloc] initWithRootViewController:viewCon];
    [[naviCon navigationBar] setBarTintColor:NAVI_COLOR];
    [[naviCon navigationBar] setTintColor:[UIColor whiteColor]];
    [naviCon navigationBar].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:20.f], UITextAttributeFont,
                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                   [UIColor grayColor], UITextAttributeTextShadowColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                   nil];
    naviCon.navigationBar.tintColor = [UIColor whiteColor];
    naviCon.navigationBar.translucent = NO;
    
    [self presentViewController:naviCon animated:YES completion:nil];
}

- (IBAction)actionPolicy:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PrivacyViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"termsview"];
    viewCon.m_bViewMode = true;
    UINavigationController *naviCon = [[UINavigationController alloc] initWithRootViewController:viewCon];
    [[naviCon navigationBar] setBarTintColor:NAVI_COLOR];
    [[naviCon navigationBar] setTintColor:[UIColor whiteColor]];
    [naviCon navigationBar].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:20.f], UITextAttributeFont,
                                                   [UIColor whiteColor], UITextAttributeTextColor,
                                                   [UIColor grayColor], UITextAttributeTextShadowColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                   nil];
    naviCon.navigationBar.tintColor = [UIColor whiteColor];
    naviCon.navigationBar.translucent = NO;
    
    [self presentViewController:naviCon animated:YES completion:nil];}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 99)
    {
        if (buttonIndex == 1)
        {
            [self logout];
        }
    }
    
    if (alertView.tag == 100)
    {
        [self logout];
    }
}

- (void) logout
{
    g_Delegate.m_bLogin = false;

    [[FacebookUtility sharedObject]logOutFromFacebook];
    [[UserDefaultHelper sharedObject] setFacebookLoginRequest:nil];

    if ([[Twitter sharedInstance] session])
    {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *each in cookieStorage.cookies) {
            // put a check here to clear cookie url which starts with twitter and then delete it
            [cookieStorage deleteCookie:each];
        }
    }
    
    [[Twitter sharedInstance] logOut];
    [[Twitter sharedInstance] logOutGuest];
    
    [g_Delegate.m_curHomeViewCon.navigationController popToRootViewControllerAnimated:YES];
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
        if (nRequestMode == DELETE_ACCOUNT_REQUEST)
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Deleted your account successfully." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alertView.tag = 100;
            [alertView show];

            return;
        }
        
        if (nRequestMode == DEACTIVATE_REQUEST)
        {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:@"Deactivated your account successfully." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alertView.tag = 100;
            [alertView show];

            return;
        }
    }
    else
    {
        [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

@end
