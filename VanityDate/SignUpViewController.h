//
//  SignUpViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrivacyViewController.h"

@class NMRangeSlider;

@interface SignUpViewController : UIViewController<UITextFieldDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UIAlertViewDelegate>
{
    UIImage* imageAvatar;
    
    NSArray* arrayData;
    
    int nChooseMode;
    
    bool bAgreeTerms;
    
    int nRequestMode;
    
    NSString* strSelectedBirth;
}

@property (weak, nonatomic) IBOutlet UIImageView *m_bgImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *m_mainScrollView;

@property (nonatomic, assign) bool m_bCreateFBUser;
@property (nonatomic, strong) NSDictionary* m_dictFBInfo;

@property (nonatomic, assign) BOOL animated;

@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;

@property (weak, nonatomic) IBOutlet UITextField *m_txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *m_txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *m_txtGender;
- (IBAction)actionChooseGender:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *m_txtBirth;
- (IBAction)actionChooseBirth:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *m_txtInterested;
- (IBAction)actionChooseInterestedIn:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *m_btnCheck;
- (IBAction)actionAgreeTerm:(id)sender;

@property (weak, nonatomic) IBOutlet NMRangeSlider *m_rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *m_lblMinAge;
@property (weak, nonatomic) IBOutlet UILabel *m_lblMaxAge;
- (IBAction)labelSliderChanged:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewChoose;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *m_lblChooseTitle;
- (IBAction)actionChooseDone:(id)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *m_pickerDOB;
@property (weak, nonatomic) IBOutlet UIPickerView *m_pickerData;

- (IBAction)actionTerms:(id)sender;
- (IBAction)actionPrivacy:(id)sender;

@end
