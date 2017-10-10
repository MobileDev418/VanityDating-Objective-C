//
//  PrivacyViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/12/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrivacyViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, assign) bool m_bViewMode;
@property (weak, nonatomic) IBOutlet UIWebView *m_webView;

@end
