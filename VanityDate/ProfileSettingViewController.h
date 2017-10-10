//
//  ProfileSettingViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEACTIVATE_REQUEST      10
#define DELETE_ACCOUNT_REQUEST  11

@interface ProfileSettingViewController : UIViewController<UIAlertViewDelegate>
{
    int nRequestMode;
}

- (IBAction)actionUpdateProfile:(id)sender;
- (IBAction)actionDeleteAccountg:(id)sender;
- (IBAction)actionDeactiveAccount:(id)sender;
- (IBAction)actionSignOut:(id)sender;
- (IBAction)actionTerms:(id)sender;
- (IBAction)actionPolicy:(id)sender;

@end
