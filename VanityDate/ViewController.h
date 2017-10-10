//
//  ViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITextFieldDelegate>
{
    int nRequestMode;
    
    NSString* strUsername;//FB : facebookid
    NSString* strPassword;//FB : accesstoken
    
    NSMutableDictionary* dictFBUserInfo;
}
@property (weak, nonatomic) IBOutlet UIImageView *m_bgImageView;

@property (nonatomic, assign) BOOL animated;

@property (weak, nonatomic) IBOutlet UITextField *m_txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPassword;

- (IBAction)actionLogin:(id)sender;
- (IBAction)actionSignUp:(id)sender;
- (IBAction)actionViaLoginWithFB:(id)sender;
- (IBAction)actionLoginViaWithTwitter:(id)sender;
- (IBAction)actionForgotPassword:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnFacebook;
@property (weak, nonatomic) IBOutlet UIButton *m_btnTwitter;

@end

