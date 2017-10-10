//
//  SignUpViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "SignUpViewController.h"
#import "Global.h"
#import "HomeViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Sign Up";
    
    self.m_bgImageView.image = [[Utils sharedObject] rn_boxblurImageWithBlur:BLUR_DEGREE exclusionPath:nil image:[UIImage imageNamed:@"bg.png"]];

    bAgreeTerms = false;
    [self.m_btnCheck setImage:[UIImage imageNamed:@"chk_off.png"] forState:UIControlStateNormal];
    
    arrayData = [NSArray arrayWithObjects:@"Male", @"Female", nil];
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    
    FAKFontAwesome *naviRightIcon = [FAKFontAwesome checkIconWithSize:NAVI_ICON_SIZE];
    [naviRightIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imageRightButton = [naviRightIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imageRightButton style:UIBarButtonItemStylePlain target:self action:@selector(actionSignUp)];

    self.m_userImageView.layer.cornerRadius = self.m_userImageView.bounds.size.height / 2;
    self.m_userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_userImageView.layer.borderWidth = 2.f;
    self.m_userImageView.clipsToBounds = YES;

    if(self.m_bCreateFBUser)
    {
        [[Utils sharedObject] loadImageFromServerAndLocal:[self.m_dictFBInfo valueForKey:@"picture"] imageView:self.m_userImageView];
        
        self.m_txtUserName.text = [self.m_dictFBInfo valueForKey:@"username"];
        self.m_txtBirth.text = [self.m_dictFBInfo valueForKey:@"birth"];
        self.m_txtEmail.text = [self.m_dictFBInfo valueForKey:@"email"];
        self.m_txtGender.text = [self.m_dictFBInfo valueForKey:@"gender"];
        
        NSURL *url = [[NSURL alloc]initWithString:[self.m_dictFBInfo valueForKey:@"picture"] ];
        NSData *imageData = [[NSData alloc]initWithContentsOfURL:url];
        
        imageAvatar = [UIImage imageWithData:imageData];

    }
    else
    {
        self.m_userImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture)];
        tapGesture.numberOfTapsRequired = 1;
        [tapGesture setDelegate:self];
        [self.m_userImageView addGestureRecognizer:tapGesture];
        
        imageAvatar = nil;
    }
    
    g_Delegate.m_bRegisterSuccess = false;

    self.m_viewChoose.hidden = YES;
    
    self.m_txtEmail.delegate = self;
    self.m_txtUserName.delegate = self;
    self.m_txtPassword.delegate = self;
    
    self.m_txtEmail.returnKeyType = UIReturnKeyNext;
    self.m_txtUserName.returnKeyType = UIReturnKeyNext;
    self.m_txtPassword.returnKeyType = UIReturnKeyDone;

    self.m_pickerData.delegate = self;
    [self.m_pickerDOB addTarget:self action:@selector(updateDOB:) forControlEvents:UIControlEventValueChanged];

    [self.m_mainScrollView setContentSize:CGSizeMake(self.view.frame.size.width,440.f)];

    [self configureLabelSlider];
    
    self.m_lblMinAge.hidden = YES;
    self.m_lblMaxAge.hidden = YES;

}

- (void) configureLabelSlider
{
    self.m_rangeSlider.maximumValue = 100;
    self.m_rangeSlider.minimumValue = 0;
    
    self.m_rangeSlider.upperValue = 100;
    self.m_rangeSlider.lowerValue = 0;
    
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


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) doSocialLogin
{
    nRequestMode = SOCIAL_LOGIN_REQUEST;
    
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    
    NSMutableDictionary * dictSessionInfo = [[UserDefaultHelper sharedObject] facebookLoginRequest];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/social_login"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:[dictSessionInfo valueForKey:@"social_id"] forKey:@"social_id"];
    [request setPostValue:g_Delegate.m_strDeviceToken forKey:@"device_id"];
    [request setPostValue:g_Delegate.m_strLatitude forKey:@"latitude"];
    [request setPostValue:g_Delegate.m_strLongitude forKey:@"longitude"];
    [request setPostValue:DEVICE_MODEL forKey:@"device_type"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [[UserDefaultHelper sharedObject] setFacebookLoginRequest:nil];
    
    [request startAsynchronous];
    
}

- (void) doLogin
{
    nRequestMode = LOGIN_REQUEST;
    
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    
    NSMutableDictionary * dictSessionInfo = [[UserDefaultHelper sharedObject] facebookLoginRequest];
    self.m_txtUserName.text = [dictSessionInfo valueForKey:@"username"];
    self.m_txtPassword.text = [dictSessionInfo valueForKey:@"password"];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/login"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request setRequestMethod:@"POST"];
    
    [request setPostValue:[dictSessionInfo valueForKey:@"username"] forKey:@"username"];
    [request setPostValue:[dictSessionInfo valueForKey:@"password"] forKey:@"password"];
    [request setPostValue:g_Delegate.m_strDeviceToken forKey:@"device_id"];
    [request setPostValue:g_Delegate.m_strLatitude forKey:@"latitude"];
    [request setPostValue:g_Delegate.m_strLongitude forKey:@"longitude"];
    [request setPostValue:DEVICE_MODEL forKey:@"device_type"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (void) actionSignUp
{
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];

    if (!imageAvatar && !self.m_bCreateFBUser)
    {
        [g_Delegate AlertWithCancel_btn:@"Please upload your photo!"];
        return;
    }
    
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
        [g_Delegate AlertWithCancel_btn:@"Please choose your birth!"];
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

    if (!bAgreeTerms)
    {
        [g_Delegate AlertWithCancel_btn:@"Please agree terms and privacy policy!"];
        return;
    }
    
    [self showLoadingView];
    
    NSString* strRegisterApi = @"account/signup";
    if (self.m_bCreateFBUser)
        strRegisterApi = @"account/social_signup";
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:strRegisterApi];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    nRequestMode = SIGNUP_REQUEST;
    
    [request setPostValue:self.m_txtUserName.text forKey:@"username"];
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

    if (self.m_bCreateFBUser)
    {
        [request setPostValue:[self.m_dictFBInfo valueForKey:@"id"] forKey:@"social_id"];
        [request setPostValue:[self.m_dictFBInfo valueForKey:@"firstname"] forKey:@"firstname"];
        [request setPostValue:[self.m_dictFBInfo valueForKey:@"lastname"] forKey:@"lastname"];
        
    }

    NSData* imageData = UIImageJPEGRepresentation(imageAvatar, 0.7f);
    [request addData:imageData withFileName:@"avatar.jpg" andContentType:@"image/jpeg" forKey:@"avatar"];

    [request setPostFormat:ASIMultipartFormDataPostFormat];
    
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

- (void) tapGesture
{
    [self openCamera];
    return;
    
    UIActionSheet *as=[[UIActionSheet alloc]initWithTitle:@"Please upload your photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo",@"Choose from Gallery", nil];
    [as showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case 0:
            [self openCamera];
            break;
        case 1:
            [self chooseFromLibaray];
            break;
        case 2:
            break;
    }
}

- (void) openCamera {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if([UIImagePickerController isSourceTypeAvailable:type])
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            type = UIImagePickerControllerSourceTypeCamera;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [[picker navigationBar] setBarTintColor:NAVI_COLOR];
        [[picker navigationBar] setTintColor:[UIColor whiteColor]];
        [picker navigationBar].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:18.0f], UITextAttributeFont,
                                                      [UIColor whiteColor], UITextAttributeTextColor,
                                                      [UIColor grayColor], UITextAttributeTextShadowColor,
                                                      [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                      nil];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:picker animated:YES completion:nil];
        });
    }
}

- (void) chooseFromLibaray {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    if([UIImagePickerController isSourceTypeAvailable:type])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.allowsEditing = YES;
        picker.delegate   = self;
        picker.sourceType = type;
        
        [[picker navigationBar] setBarTintColor:NAVI_COLOR];
        [[picker navigationBar] setTintColor:[UIColor whiteColor]];
        [picker navigationBar].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:18.0f], UITextAttributeFont,
                                                      [UIColor whiteColor], UITextAttributeTextColor,
                                                      [UIColor grayColor], UITextAttributeTextShadowColor,
                                                      [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                      nil];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self presentViewController:picker animated:YES completion:nil];
        });
        
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage* selectedImage = [[info valueForKey:UIImagePickerControllerEditedImage] fixOrientation];
    
    imageAvatar = selectedImage;
    
    self.m_userImageView.image = selectedImage;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    self.m_txtEmail.delegate = self;
    self.m_txtUserName.delegate = self;
    self.m_txtPassword.delegate = self;

    if (textField == self.m_txtUserName)
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
        [self.m_txtUserName resignFirstResponder];
        [self.m_txtPassword resignFirstResponder];
        
        return NO;
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtEmail resignFirstResponder];
    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
}

-(void)keyboardWillShow {
    self.m_viewChoose.hidden = YES;
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

    if (textField == self.m_txtEmail) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 4, rectScreen.size.width, rectScreen.size.height - 64);
        }];
        self.animated = YES;
    }

    if (textField == self.m_txtPassword) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, -34, rectScreen.size.width, rectScreen.size.height - 64);
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

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
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

    nChooseMode = 3;
    
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
    
    if (nChooseMode == 3)
    {
        strSelectedBirth = [[Utils sharedObject] DateToString:self.m_pickerDOB.date withFormat:@"yyyy-MM-dd"];
        self.m_txtBirth.text = [[Utils sharedObject] DateToString:self.m_pickerDOB.date withFormat:@"MMM dd, yyyy"];

        return;
    }
    
    int nSelRow = (int)[self.m_pickerData selectedRowInComponent:0];
    if (nChooseMode == 1)
    {
        self.m_txtGender.text = [arrayData objectAtIndex:nSelRow];
/*
        if ([[self.m_txtGender.text lowercaseString] isEqualToString:@"male"])
            self.m_txtInterested.text = @"Female";
        else
            self.m_txtInterested.text = @"Male";
 */
    }
    else
        self.m_txtInterested.text = [arrayData objectAtIndex:nSelRow];

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
    
    if (dictResponse == nil)
    {
        [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
        return;
    }
    
    if (nRequestMode == SOCIAL_LOGIN_REQUEST)
    {
        if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
        {
            //success
            g_Delegate.m_dictCurrentUser = [NSMutableDictionary dictionaryWithDictionary:dictResponse];
            g_Delegate.m_strAccessToken = [dictResponse valueForKey:@"Access-Token"];
            g_Delegate.m_strAccessDeviceId = [dictResponse valueForKey:@"Device-Id"];
            
            g_Delegate.m_curUserInfo = [[dictResponse valueForKey:@"userinfo"] mutableCopy];
            g_Delegate.m_strCurUserProfileImage = [dictResponse valueForKey:@"avatar"];
            
            NSLog(@"social login session info = %@", g_Delegate.m_socialSessionInfo);
            
            [[UserDefaultHelper sharedObject] setFacebookLoginRequest:g_Delegate.m_socialSessionInfo];
            
            [self goToHomeView];
            
        }
        else
        {
            [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
        }
        
    }

    if (nRequestMode == LOGIN_REQUEST)
    {
        if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
        {
            //success
            g_Delegate.m_dictCurrentUser = [NSMutableDictionary dictionaryWithDictionary:dictResponse];
            g_Delegate.m_strAccessToken = [dictResponse valueForKey:@"Access-Token"];
            g_Delegate.m_strAccessDeviceId = [dictResponse valueForKey:@"Device-Id"];
            
            g_Delegate.m_curUserInfo = [[dictResponse valueForKey:@"userinfo"] mutableCopy];
            g_Delegate.m_strCurUserProfileImage = [dictResponse valueForKey:@"avatar"];
            
            NSMutableDictionary *dictSessionInfo = [[NSMutableDictionary alloc] init];
            
            [dictSessionInfo setValue:self.m_txtUserName.text forKey:@"username"];
            [dictSessionInfo setValue:self.m_txtPassword.text forKey:@"password"];
            [dictSessionInfo setValue:g_Delegate.m_strDeviceToken forKey:@"pushId"];
            [dictSessionInfo setValue:@"userByEmail" forKey:@"loginmode"];
            
            [[UserDefaultHelper sharedObject] setFacebookLoginRequest:dictSessionInfo];
            
            [self goToHomeView];
            
        }
        else
        {
            //
            if ([[dictResponse valueForKey:@"message"] rangeOfString:@"not exist"].location != NSNotFound)
                [g_Delegate AlertWithCancel_btn:@"There is no account with this username!"];
            else
                [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
        }
    }

    if (nRequestMode == SIGNUP_REQUEST)
    {
        if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
        {
            //success
            g_Delegate.m_bRegisterSuccess = false;
            
            NSMutableDictionary *dictSessionInfo = [[NSMutableDictionary alloc] init];
            
            if (self.m_bCreateFBUser)
            {
                [dictSessionInfo setValue:[self.m_dictFBInfo valueForKey:@"id"] forKey:@"social_id"];
                [dictSessionInfo setValue:g_Delegate.m_strDeviceToken forKey:@"pushId"];
                if (g_Delegate.m_nRegisterMode == FACEBOOK_REGISTER)
                    [dictSessionInfo setValue:@"userByFB" forKey:@"loginmode"];
                else
                    [dictSessionInfo setValue:@"userByTwitter" forKey:@"loginmode"];
            }
            else
            {
                [dictSessionInfo setValue:self.m_txtUserName.text forKey:@"username"];
                [dictSessionInfo setValue:self.m_txtPassword.text forKey:@"password"];
                [dictSessionInfo setValue:g_Delegate.m_strDeviceToken forKey:@"pushId"];
                [dictSessionInfo setValue:@"userByEmail" forKey:@"loginmode"];
            }
            
            [[UserDefaultHelper sharedObject] setFacebookLoginRequest:dictSessionInfo];
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SUCCESS_STRING message:@"Welcome to Vanity Dating!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
        else
        {
            //
            [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
        }
    }
}

- (void) goToHomeView
{
    g_Delegate.m_bLogin = true;
    g_Delegate.m_bRegisterSuccess = false;
    
    self.navigationController.navigationBarHidden = YES;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    HomeViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"homeview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    g_Delegate.m_bRegisterSuccess = true;
    
//    [self.navigationController popViewControllerAnimated:YES];
    NSString* strLoginMode = [[[UserDefaultHelper sharedObject] facebookLoginRequest] valueForKey:@"loginmode"];
    if ([strLoginMode isEqualToString:@"userByFB"])
    {
        [self socialLoginWithoutInput];
    }
    else if ([strLoginMode isEqualToString:@"userByTwitter"])
    {
        [self socialLoginWithoutInput];
    }
    else
    {
        [self loginWithoutInput];
    }

}

- (void) socialLoginWithoutInput
{
    [self showLoadingView];
    
    [self performSelector:@selector(doSocialLogin) withObject:nil afterDelay:1.f];
}

- (void) loginWithoutInput
{
    [self showLoadingView];
    
    [self performSelector:@selector(doLogin) withObject:nil afterDelay:1.f];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

- (IBAction)actionAgreeTerm:(id)sender {
    if (bAgreeTerms)
    {
        bAgreeTerms = false;
        [self.m_btnCheck setImage:[UIImage imageNamed:@"chk_off.png"] forState:UIControlStateNormal];
    }
    else
    {
        bAgreeTerms = true;
        [self.m_btnCheck setImage:[UIImage imageNamed:@"chk_on.png"] forState:UIControlStateNormal];
    }
}
- (IBAction)actionTerms:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PrivacyViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"termsview"];
    viewCon.m_bViewMode = false;
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

    [self presentViewController:naviCon animated:YES completion:nil];
}

- (IBAction)actionPrivacy:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    PrivacyViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"termsview"];
    viewCon.m_bViewMode = true;
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
    
    [self presentViewController:naviCon animated:YES completion:nil];
}

@end
