//
//  HomeViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "HomeViewController.h"
#import "FavoriteViewController.h"
#import "EventViewController.h"
#import "ChatListViewController.h"
#import "ProfileViewController.h"
#import "Global.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    badgeView = [[JSBadgeView alloc] initWithParentView:self.m_imageChat alignment:JSBadgeViewAlignmentTopRight];
    badgeView.badgeText = [NSString stringWithFormat:@"%d", 0];
    badgeView.hidden = YES;

    self.m_viewSelected.center = self.m_view2.center;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    EventViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"eventview"];
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
    [self addChildViewController:naviCon];
    [self.m_subView addSubview:naviCon.view];
    [naviCon didMoveToParentViewController:self];
    
    curNavCon = naviCon;
    
    [g_Delegate loadMissedChatHistory:false];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) setBadgeNum:(int) nVal
{
    badgeView.badgeText = [NSString stringWithFormat:@"%d", nVal];
    
    if (nVal == 0)
        badgeView.hidden = YES;
    else
        badgeView.hidden = NO;
}

- (void) hideMenuTabView
{
    if (self.m_tabBar.center.y >= self.view.frame.size.height + MENU_TAB_HEIGHT / 2.f)
        return;
    
    [UIView animateWithDuration:INDICATOR_ANIMATION
                          delay:0.f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.m_tabBar.center = CGPointMake(self.m_tabBar.center.x, self.view.frame.size.height + MENU_TAB_HEIGHT / 2.f);
     }
                     completion:^(BOOL finished)
     {
     }];
}

- (void) showMenuTabView
{
    if (self.m_tabBar.center.y <= self.view.frame.size.height - MENU_TAB_HEIGHT / 2.f)
        return;

    [UIView animateWithDuration:INDICATOR_ANIMATION
                          delay:0.f
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         self.m_tabBar.center = CGPointMake(self.m_tabBar.center.x, self.view.frame.size.height - MENU_TAB_HEIGHT / 2.f);
     }
                     completion:^(BOOL finished)
     {
     }];
}

- (void) viewWillAppear:(BOOL)animated
{
    g_Delegate.m_curHomeViewCon = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    g_Delegate.m_curHomeViewCon = nil;
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

- (IBAction)actionView1:(id)sender {
    [curNavCon willMoveToParentViewController:nil];
    [curNavCon.view removeFromSuperview];
    curNavCon = nil;

    self.m_viewSelected.center = self.m_view1.center;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FavoriteViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"favoriteview"];
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
    [self addChildViewController:naviCon];
    [self.m_subView addSubview:naviCon.view];
    [naviCon didMoveToParentViewController:self];
    
    curNavCon = naviCon;
}

- (IBAction)actionView2:(id)sender {
    [curNavCon willMoveToParentViewController:nil];
    [curNavCon.view removeFromSuperview];
    curNavCon = nil;

    self.m_viewSelected.center = self.m_view2.center;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    EventViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"eventview"];
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
    [self addChildViewController:naviCon];
    [self.m_subView addSubview:naviCon.view];
    [naviCon didMoveToParentViewController:self];
    
    curNavCon = naviCon;
}

- (IBAction)actionView3:(id)sender {
    [curNavCon willMoveToParentViewController:nil];
    [curNavCon.view removeFromSuperview];
    curNavCon = nil;

    self.m_viewSelected.center = self.m_view3.center;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ChatListViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"chatlistview"];
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
    [self addChildViewController:naviCon];
    [self.m_subView addSubview:naviCon.view];
    [naviCon didMoveToParentViewController:self];
    
    curNavCon = naviCon;
}

- (IBAction)actionView4:(id)sender {
    [curNavCon willMoveToParentViewController:nil];
    [curNavCon.view removeFromSuperview];
    curNavCon = nil;

    self.m_viewSelected.center = self.m_view4.center;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    ProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"profileview"];
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
    [self addChildViewController:naviCon];
    [self.m_subView addSubview:naviCon.view];
    [naviCon didMoveToParentViewController:self];
    
    curNavCon = naviCon;
}

@end

