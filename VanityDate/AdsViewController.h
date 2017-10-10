//
//  AdsViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 8/28/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdsViewController : UIViewController
{
    NSDictionary* dictAdsInfo;
    
}

@property (weak, nonatomic) IBOutlet UIImageView *m_imageView;

@property (weak, nonatomic) IBOutlet UIButton *m_btnClose;
- (IBAction)actionClose:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnAction;
- (IBAction)actionGotoSite:(id)sender;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_activity;

@property (weak, nonatomic) IBOutlet UIView *m_viewContainer;
@end
