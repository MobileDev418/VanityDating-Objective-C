//
//  PrivacyViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/12/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "PrivacyViewController.h"
#import "Global.h"

@interface PrivacyViewController ()

@end

@implementation PrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    self.m_webView.delegate = self;
    
    NSString* strLink = @"";
    if (self.m_bViewMode)
    {
        strLink = @"http://vanitydating.com/privacy-policy";
        self.navigationItem.title = @"Privacy Policy";
    }
    else
    {
        strLink = @"http://vanitydating.com/terms-conditions";
        self.navigationItem.title = @"Terms & Conditions";
    }
    
    NSURL *url = [[NSURL alloc] initWithString:strLink];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self.m_webView.delegate = self;
    
    [self.m_webView loadRequest:requestObj];
}

- (void) backToMainView
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoadingView];
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

@end
