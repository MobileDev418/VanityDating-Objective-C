//
//  ProfileEditViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ProfileEditViewController.h"
#import "Global.h"
#import "HomeViewController.h"

@interface ProfileEditViewController ()

@end

@implementation ProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Update Profile";

    arrayData = [NSArray arrayWithObjects:@"Male", @"Female", nil];

    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgButton = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgButton style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    
    FAKFontAwesome *naviRightIcon = [FAKFontAwesome checkIconWithSize:NAVI_ICON_SIZE];
    [naviRightIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imageRightButton = [naviRightIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imageRightButton style:UIBarButtonItemStylePlain target:self action:@selector(saveSetting)];
    
    self.m_viewChoose.hidden = YES;
    
    self.m_txtEmail.delegate = self;
    self.m_txtUserName.delegate = self;
    self.m_txtPassword.delegate = self;
    self.m_txtFirstName.delegate = self;
    self.m_txtLastName.delegate = self;

    self.m_txtEmail.returnKeyType = UIReturnKeyNext;
    self.m_txtFirstName.returnKeyType = UIReturnKeyNext;
    self.m_txtLastName.returnKeyType = UIReturnKeyNext;
    self.m_txtUserName.returnKeyType = UIReturnKeyNext;
    self.m_txtPassword.returnKeyType = UIReturnKeyDone;

    NSLog(@"%@", g_Delegate.m_curUserInfo);
    [self.m_txtUserName setEnabled:NO];
    
    self.m_txtPassword.text = [[[UserDefaultHelper sharedObject] facebookLoginRequest] valueForKey:@"password"];
    self.m_txtEmail.text = [[Utils sharedObject] checkAvaiablityForString:[g_Delegate.m_curUserInfo valueForKey:@"email"]];
    self.m_txtUserName.text = [[Utils sharedObject] checkAvaiablityForString:[g_Delegate.m_curUserInfo valueForKey:@"username"]];
    self.m_txtFirstName.text = [[Utils sharedObject] checkAvaiablityForString:[g_Delegate.m_curUserInfo valueForKey:@"firstname"]];
    self.m_txtLastName.text = [[Utils sharedObject] checkAvaiablityForString:[g_Delegate.m_curUserInfo valueForKey:@"lastname"]];
    
    NSDate* dateBirth = [[Utils sharedObject] StringToDate:[[Utils sharedObject] checkAvaiablityForString:[g_Delegate.m_curUserInfo valueForKey:@"birthday"]] withFormat:@"yyyy-MM-dd"];
    strSelectedBirth = [[Utils sharedObject] checkAvaiablityForString:[g_Delegate.m_curUserInfo valueForKey:@"birthday"]];
    self.m_txtBirth.text = [[Utils sharedObject] DateToString:dateBirth withFormat:@"MMM dd, yyyy"];
    
    int nGender = (int)[[g_Delegate.m_curUserInfo valueForKey:@"gender"] integerValue];
    int nInterested = (int)[[g_Delegate.m_curUserInfo valueForKey:@"interested_in"] integerValue];
    
    self.m_txtGender.text = [arrayData objectAtIndex:nGender - 1];
    /*
    if ([[self.m_txtGender.text lowercaseString] isEqualToString:@"male"])
        self.m_txtInterested.text = @"Female";
    else
        self.m_txtInterested.text = @"Male";
     */
    self.m_txtInterested.text = [arrayData objectAtIndex:nInterested - 1];
    
    self.m_pickerData.delegate = self;
    [self.m_pickerDOB addTarget:self action:@selector(updateDOB:) forControlEvents:UIControlEventValueChanged];
    
    [self.m_mainScrollView setContentSize:CGSizeMake(self.view.frame.size.width,520)];
    
    [self configureLabelSlider];
    
    self.m_lblMinAge.hidden = YES;
    self.m_lblMaxAge.hidden = YES;
}

- (void) configureLabelSlider
{
    self.m_rangeSlider.maximumValue = 100;
    self.m_rangeSlider.minimumValue = 0;
    
    self.m_rangeSlider.upperValue = [[g_Delegate.m_curUserInfo valueForKey:@"age_max"] integerValue] - 10;
    self.m_rangeSlider.lowerValue = [[g_Delegate.m_curUserInfo valueForKey:@"age_min"] integerValue] - 18;
    
    self.m_rangeSlider.minimumRange = 10;
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    self.m_lblMinAge.hidden = NO;
    self.m_lblMaxAge.hidden = NO;

    CGPoint lowerCenter;
    lowerCenter.x = (self.m_rangeSlider.lowerCenter.x + self.m_rangeSlider.frame.origin.x);
    lowerCenter.y = (self.m_rangeSlider.center.y - 30.0f);
    self.m_lblMinAge.center = lowerCenter;
    self.m_lblMinAge.text = [NSString stringWithFormat:@"%d", (int)self.m_rangeSlider.lowerValue + 18];
    
    CGPoint upperCenter;
    upperCenter.x = (self.m_rangeSlider.upperCenter.x + self.m_rangeSlider.frame.origin.x);
    upperCenter.y = (self.m_rangeSlider.center.y - 30.0f);
    self.m_lblMaxAge.center = upperCenter;
    self.m_lblMaxAge.text = [NSString stringWithFormat:@"%d", (int)self.m_rangeSlider.upperValue + 10];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}


- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveSetting
{
    if (self.m_txtUserName.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input your username!"];
        return;
    }
    
    if (self.m_txtUserName.text.length < 4)
    {
        [g_Delegate AlertWithCancel_btn:@"User name length has to be 4 letters at least!"];
        return;
    }

    if (self.m_txtFirstName.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input your first name!"];
        return;
    }

    if (self.m_txtLastName.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input your last name!"];
        return;
    }

    if (self.m_txtEmail.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input your email!"];
        return;
    }
    
    if (![[Utils sharedObject] validateEmail:self.m_txtEmail.text])
    {
        [g_Delegate AlertWithCancel_btn:@"Please input valid email!"];
        return;
    }
    
    if (self.m_txtPassword.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input your password!"];
        return;
    }
    
    if (self.m_txtPassword.text.length < 6)
    {
        [g_Delegate AlertWithCancel_btn:@"Password length has to be 6 letters at least!"];
        return;
    }

    if (self.m_txtGender.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please choose your gender!"];
        return;
    }
    
    if (self.m_txtBirth.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please choose your birthday!"];
        return;
    }
    
    if (![[Utils sharedObject] checkAvailableBirth:strSelectedBirth])
    {
        [g_Delegate AlertWithCancel_btn:@"You must be at least 18 years old to use Vanity Dating."];
        return;
    }

    if (self.m_txtInterested.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please choose your interest!"];
        return;
    }
    
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];

    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/update_profile"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];

    [request setPostValue:self.m_txtUserName.text forKey:@"username"];
    [request setPostValue:self.m_txtFirstName.text forKey:@"first_name"];
    [request setPostValue:self.m_txtLastName.text forKey:@"last_name"];
    [request setPostValue:self.m_txtEmail.text forKey:@"email"];
    [request setPostValue:self.m_txtPassword.text forKey:@"password"];
    [request setPostValue:strSelectedBirth forKey:@"birthday"];
    [request setPostValue:self.m_lblMaxAge.text forKey:@"age_max"];
    [request setPostValue:self.m_lblMinAge.text forKey:@"age_min"];

    if ([[self.m_txtGender.text lowercaseString] isEqualToString:@"male"])
        [request setPostValue:@"1" forKey:@"gender"];
    else
        [request setPostValue:@"2" forKey:@"gender"];
    
    if ([[self.m_txtInterested.text lowercaseString] isEqualToString:@"male"])
        [request setPostValue:@"1" forKey:@"interested_in"];
    else
        [request setPostValue:@"2" forKey:@"interested_in"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];

}

- (void) updateDOB:(UIDatePicker *)datePicker
{
    strSelectedBirth = [[Utils sharedObject] DateToString:datePicker.date withFormat:@"yyyy-MM-dd"];
    self.m_txtBirth.text = [[Utils sharedObject] DateToString:datePicker.date withFormat:@"MMM dd, yyyy"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32.f;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [arrayData count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [arrayData objectAtIndex:row];
}

// Picker Delegate
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (nChooseMode == 1)
    {
        self.m_txtGender.text = [arrayData objectAtIndex:row];
        /*
        if ([[self.m_txtGender.text lowercaseString] isEqualToString:@"male"])
            self.m_txtInterested.text = @"Female";
        else
            self.m_txtInterested.text = @"Male";
         */

    }
    else
        self.m_txtInterested.text = [arrayData objectAtIndex:row];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [g_Delegate.m_curHomeViewCon hideMenuTabView];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [g_Delegate.m_curHomeViewCon showMenuTabView];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self updateSliderLabels];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.m_txtUserName)
    {
        [self.m_txtFirstName becomeFirstResponder];
        return YES;
    }
    else if (textField == self.m_txtFirstName)
    {
        [self.m_txtLastName becomeFirstResponder];
        return YES;
    }
    else if (textField == self.m_txtLastName)
    {
        [self.m_txtEmail becomeFirstResponder];
        return YES;
    }
    else if (textField == self.m_txtEmail)
    {
        [self.m_txtPassword becomeFirstResponder];
        return YES;
    }
    else
    {
        [self.m_txtEmail resignFirstResponder];
        [self.m_txtFirstName resignFirstResponder];
        [self.m_txtLastName resignFirstResponder];
        [self.m_txtUserName resignFirstResponder];
        [self.m_txtPassword resignFirstResponder];
        
        return NO;
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtFirstName resignFirstResponder];
    [self.m_txtLastName resignFirstResponder];
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
}

-(void)keyboardWillShow {
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    if (textField == self.m_txtUserName) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 64, rectScreen.size.width, rectScreen.size.height - 64);
        }];
        self.animated = YES;
    }
    
    if (textField == self.m_txtFirstName) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 34, rectScreen.size.width, rectScreen.size.height - 64);
        }];
        self.animated = YES;
    }
    
    if (textField == self.m_txtLastName) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 4, rectScreen.size.width, rectScreen.size.height - 64);
        }];
        self.animated = YES;
    }

    if (textField == self.m_txtEmail) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -30, rectScreen.size.width, rectScreen.size.height - 64);
        }];
        self.animated = YES;
    }
    
    if (textField == self.m_txtPassword) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -60, rectScreen.size.width, rectScreen.size.height - 64);
        }];
        self.animated = YES;
    }

    return YES;
}

-(void)keyboardWillHide {
    CGRect rectScreen = [[UIScreen mainScreen] bounds];
    
    // Animate the current view back to its original position
    if (self.animated) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 64, rectScreen.size.width, rectScreen.size.height - 64);
        }];
        self.animated = NO;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionChooseGender:(id)sender {
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    
    nChooseMode = 1;
    
    self.m_viewChoose.hidden = NO;
    self.m_lblChooseTitle.title = @"Please choose your gender";
    
    self.m_pickerData.hidden = NO;
    self.m_pickerDOB.hidden = YES;
}

- (IBAction)actionChooseBirth:(id)sender {
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    
    self.m_viewChoose.hidden = NO;
    self.m_lblChooseTitle.title = @"Please choose your birthday";
    
    self.m_pickerData.hidden = YES;
    self.m_pickerDOB.hidden = NO;
}

- (IBAction)actionChooseInterestedIn:(id)sender {
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    
    nChooseMode = 2;
    
    self.m_viewChoose.hidden = NO;
    self.m_lblChooseTitle.title = @"Please choose your interest";
    
    self.m_pickerData.hidden = NO;
    self.m_pickerDOB.hidden = YES;
}

- (IBAction)actionChooseDone:(id)sender {
    self.m_viewChoose.hidden = YES;
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
    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        [g_Delegate AlertSuccess:@"Updated profile successfully."];
        
        NSMutableDictionary* saveLoginData = [[[UserDefaultHelper sharedObject] facebookLoginRequest] mutableCopy];
        [saveLoginData setValue:self.m_txtPassword.text forKey:@"password"];
        
        [[UserDefaultHelper sharedObject] setFacebookLoginRequest:saveLoginData];

        NSLog(@"%@-%@", self.m_lblMaxAge.text, self.m_lblMinAge.text);
        
        [g_Delegate.m_curUserInfo setValue:self.m_lblMinAge.text forKey:@"age_min"];
        [g_Delegate.m_curUserInfo setValue:self.m_lblMaxAge.text forKey:@"age_max"];
        [g_Delegate.m_curUserInfo setValue:self.m_txtEmail.text forKey:@"email"];
        [g_Delegate.m_curUserInfo setValue:self.m_txtFirstName.text forKey:@"firstname"];
        [g_Delegate.m_curUserInfo setValue:self.m_txtLastName.text forKey:@"lastname"];
        [g_Delegate.m_curUserInfo setValue:strSelectedBirth forKey:@"birthday"];
        if ([[self.m_txtGender.text lowercaseString] isEqualToString:@"male"])
            [g_Delegate.m_curUserInfo setValue:@"1" forKey:@"gender"];
        else
            [g_Delegate.m_curUserInfo setValue:@"2" forKey:@"gender"];
        
        if ([[self.m_txtInterested.text lowercaseString] isEqualToString:@"male"])
            [g_Delegate.m_curUserInfo setValue:@"1" forKey:@"interested_in"];
        else
            [g_Delegate.m_curUserInfo setValue:@"2" forKey:@"interested_in"];
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
