//
//  ProfileEditViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NMRangeSlider;

@interface ProfileEditViewController : UIViewController<UITextFieldDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate, UIAlertViewDelegate>
{
    NSArray* arrayData;
    
    int nChooseMode;
    
    NSString* strSelectedBirth;
    
}

@property (nonatomic, assign) BOOL animated;

@property (weak, nonatomic) IBOutlet UIScrollView *m_mainScrollView;
@property (weak, nonatomic) IBOutlet UITextField *m_txtUserName;
@property (weak, nonatomic) IBOutlet UITextField *m_txtFirstName;
@property (weak, nonatomic) IBOutlet UITextField *m_txtLastName;


@property (weak, nonatomic) IBOutlet UITextField *m_txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *m_txtGender;
- (IBAction)actionChooseGender:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *m_txtBirth;
- (IBAction)actionChooseBirth:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *m_txtInterested;
- (IBAction)actionChooseInterestedIn:(id)sender;
@property (weak, nonatomic) IBOutlet NMRangeSlider *m_rangeSlider;
@property (weak, nonatomic) IBOutlet UILabel *m_lblMinAge;
@property (weak, nonatomic) IBOutlet UILabel *m_lblMaxAge;

- (IBAction)labelSliderChanged:(NMRangeSlider*)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewChoose;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *m_lblChooseTitle;
- (IBAction)actionChooseDone:(id)sender;

@property (weak, nonatomic) IBOutlet UIDatePicker *m_pickerDOB;
@property (weak, nonatomic) IBOutlet UIPickerView *m_pickerData;

@end
