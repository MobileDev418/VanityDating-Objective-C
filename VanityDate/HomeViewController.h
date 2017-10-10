//
//  HomeViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

@interface HomeViewController : UIViewController
{
    UINavigationController* curNavCon;
    JSBadgeView* badgeView;
}

@property (weak, nonatomic) IBOutlet UIView *m_subView;

@property (weak, nonatomic) IBOutlet UIView *m_tabBar;

@property (weak, nonatomic) IBOutlet UIImageView *m_viewSelected;

@property (weak, nonatomic) IBOutlet UIView *m_view1;
- (IBAction)actionView1:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_view2;
- (IBAction)actionView2:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_view3;
- (IBAction)actionView3:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_view4;
- (IBAction)actionView4:(id)sender;

- (void) hideMenuTabView;
- (void) showMenuTabView;

- (void) setBadgeNum:(int) nVal;
@property (weak, nonatomic) IBOutlet UIImageView *m_imageChat;

@end
