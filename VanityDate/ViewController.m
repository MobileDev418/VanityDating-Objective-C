//
//  ViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ViewController.h"
#import "Global.h"
#import "SignUpViewController.h"
#import "HomeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = YES;

    self.m_bgImageView.image = [[Utils sharedObject] rn_boxblurImageWithBlur:BLUR_DEGREE exclusionPath:nil image:[UIImage imageNamed:@"bg.png"]];
    
    dictFBUserInfo = [[NSMutableDictionary alloc] init];

    g_Delegate.m_bRegisterSuccess = false;
    
    [[self.navigationController navigationBar] setTintColor:[UIColor whiteColor]];
    [[self.navigationController navigationBar] setBarTintColor:NAVI_COLOR];
    [self.navigationController navigationBar].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                     [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:18.0f], UITextAttributeFont,
                                                                     [UIColor whiteColor], UITextAttributeTextColor,
                                                                     [UIColor grayColor], UITextAttributeTextShadowColor,
                                                                     [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                                     nil];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navi_bar.png"]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    self.m_txtPassword.delegate = self;
    self.m_txtUserName.delegate = self;
    
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void) viewDidAppear:(BOOL)animated
{
    if (g_Delegate.m_bRegisterSuccess)
    {
        g_Delegate.m_bRegisterSuccess = false;
        
        /*
        if (g_Delegate.m_nRegisterMode == SOCIAL_REGISTER)
            [self socialLoginWithoutInput];
        else
            [self loginWithoutInput];
         */
        NSString* strLoginMode = [[[UserDefaultHelper sharedObject] facebookLoginRequest] valueForKey:@"loginmode"];
        if ([strLoginMode isEqualToString:@"userByFB"])
        {
            [self.m_btnFacebook setTitle:@"Logout" forState:UIControlStateNormal];
            [self socialLoginWithoutInput];
        }
        else if ([strLoginMode isEqualToString:@"userByTwitter"])
        {
            [self.m_btnTwitter setTitle:@"Logout" forState:UIControlStateNormal];
            [self socialLoginWithoutInput];
        }
        else
        {
            [self loginWithoutInput];
        }

        
        return;
    }
    
    if ([[UserDefaultHelper sharedObject] facebookLoginRequest])
    {
        NSString* strLoginMode = [[[UserDefaultHelper sharedObject] facebookLoginRequest] valueForKey:@"loginmode"];
        if ([strLoginMode isEqualToString:@"userByFB"])
        {
            [self.m_btnFacebook setTitle:@"Logout" forState:UIControlStateNormal];
            [self socialLoginWithoutInput];
        }
        else if ([strLoginMode isEqualToString:@"userByTwitter"])
        {
            [self.m_btnTwitter setTitle:@"Logout" forState:UIControlStateNormal];
            [self socialLoginWithoutInput];
        }
        else
        {
            [self loginWithoutInput];
        }
    }
    else
    {
        [self.m_btnFacebook setTitle:@"Login via Facebook" forState:UIControlStateNormal];
        [self.m_btnTwitter setTitle:@"Login via Twitter" forState:UIControlStateNormal];
    }

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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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
            self.view.frame = CGRectMake(0, 0, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = YES;
    }
    
    if (textField == self.m_txtPassword) {
        [UIView animateWithDuration:0.3f animations:^ {
            self.view.frame = CGRectMake(0, 0, rectScreen.size.width, rectScreen.size.height);
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
            self.view.frame = CGRectMake(0, 0, rectScreen.size.width, rectScreen.size.height);
        }];
        self.animated = NO;
    }
}

- (void) showLoadingView
{
    MBProgressHUD *progressHUB = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:progressHUB];
    progressHUB.tag = 100;
    
    [progressHUB show:YES];
    
}

- (void) hideLoadingView
{
    MBProgressHUD* progressHUB = (MBProgressHUD *)[self.view viewWithTag:100];
    if (progressHUB)
    {
        [progressHUB hide:YES];
        [progressHUB removeFromSuperview];
        progressHUB = nil;
    }
}

- (void) goToHomeView
{
    g_Delegate.m_bLogin = true;
    g_Delegate.bLoadAds = false;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    HomeViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"homeview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];

}

- (void) viewWillAppear:(BOOL)animated
{
    self.m_txtUserName.text = @"";
    self.m_txtPassword.text = @"";

    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionLogin:(id)sender {
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
    
    if (self.m_txtPassword.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input your password!"];
        return;
    }

    [self.m_txtUserName resignFirstResponder];
    [self.m_txtPassword resignFirstResponder];
    
    [self showLoadingView];
    
    nRequestMode = LOGIN_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/login"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request setRequestMethod:@"POST"];

    [request setPostValue:self.m_txtUserName.text forKey:@"username"];
    [request setPostValue:self.m_txtPassword.text forKey:@"password"];
    [request setPostValue:g_Delegate.m_strDeviceToken forKey:@"device_id"];
    [request setPostValue:g_Delegate.m_strLatitude forKey:@"latitude"];
    [request setPostValue:g_Delegate.m_strLongitude forKey:@"longitude"];
    [request setPostValue:DEVICE_MODEL forKey:@"device_type"];

    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
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

- (IBAction)actionSignUp:(id)sender {
    g_Delegate.m_bRegisterSuccess = false;

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    SignUpViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"signupview"];
    viewCon.m_bCreateFBUser = false;
    g_Delegate.m_nRegisterMode = EMAIL_REGISTER;
    
    [self.navigationController pushViewController:viewCon animated:YES];
}

- (IBAction)actionViaLoginWithFB:(id)sender {
    if ([FacebookUtility sharedObject].session.state!=FBSessionStateOpen){
        [[FacebookUtility sharedObject]getFBToken];
    }
    
    if ([[FacebookUtility sharedObject]isLogin])
    {
        [self getFacebookUserDetails];
    }
    else{
        [[FacebookUtility sharedObject]loginInFacebook:^(BOOL success, NSError *error) {
            if (success) {
                if ([FacebookUtility sharedObject].session.state==FBSessionStateOpen)
                {
                    [self getFacebookUserDetails];
                }
            }
            else{
                [self hideLoadingView];

                /*
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Error"
                                          message:error.localizedDescription
                                          delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                [alertView show];
                 */
            }
        }];
    }
}

-(void)getFacebookUserDetails
{
    //me?fields=id,birthday,gender,first_name,age_range,last_name,name,picture.type(normal)
    [self showLoadingView];
    
    if ([[FacebookUtility sharedObject]isLogin]) {
        [[FacebookUtility sharedObject]fetchMeWithFields:@"id,birthday,gender,email,first_name,age_range,last_name,name,picture.type(normal)" FBCompletionBlock:^(id response, NSError *error)
         {
             if (!error) {
                 [[UserDefaultHelper sharedObject] setFacebookUserDetail:[NSMutableDictionary dictionaryWithDictionary:response]];
                 [self parseLogin:response];
             }
             else{
                 [self hideLoadingView];
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Can not connect to facebook!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                 alert.tag = 202;
                 [alert show];
             }
         }];
    }
    else{
        [self hideLoadingView];
    }
    
}

-(void)parseLogin :(NSDictionary*)FBUserDetailDict
{
    [self hideLoadingView];
    
    NSString *strAccessToken = [FacebookUtility sharedObject].session.accessTokenData.accessToken;
    
    strUsername = [FBUserDetailDict valueForKey:@"id"];
    strPassword = strAccessToken;

    NSDate* dateFBUserBirth = [[Utils sharedObject] StringToDate:[FBUserDetailDict valueForKey:@"birthday"] withFormat:@"MM/dd/yyyy"];
    NSString* strBirth = [[Utils sharedObject] DateToString:dateFBUserBirth withFormat:@"yyyy-MM-dd"];
    
    NSString* strProfileLink = [[[FBUserDetailDict valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
    [dictFBUserInfo setValue:@"" forKey:@"username"];
    [dictFBUserInfo setValue:[FBUserDetailDict valueForKey:@"id"] forKey:@"id"];
    [dictFBUserInfo setValue:strAccessToken forKey:@"accessToken"];
    [dictFBUserInfo setValue:[FBUserDetailDict valueForKey:@"first_name"] forKey:@"firstName"];
    [dictFBUserInfo setValue:[FBUserDetailDict valueForKey:@"last_name"] forKey:@"lastName"];
    [dictFBUserInfo setValue:[FBUserDetailDict valueForKey:@"gender"] forKey:@"gender"];
    [dictFBUserInfo setValue:strBirth forKey:@"birth"];
    [dictFBUserInfo setValue:[FBUserDetailDict valueForKey:@"email"] forKey:@"email"];
    [dictFBUserInfo setValue:strProfileLink forKey:@"picture"];

    NSMutableDictionary *dictSessionInfo = [[NSMutableDictionary alloc] init];
    
    [dictSessionInfo setValue:[FBUserDetailDict valueForKey:@"id"] forKey:@"social_id"];
    [dictSessionInfo setValue:g_Delegate.m_strDeviceToken forKey:@"pushId"];
    [dictSessionInfo setValue:@"userByFB" forKey:@"loginmode"];
    
    g_Delegate.m_socialSessionInfo = [dictSessionInfo mutableCopy];
    g_Delegate.m_nRegisterMode = FACEBOOK_REGISTER;
    
    [[UserDefaultHelper sharedObject] setFacebookLoginRequest:dictSessionInfo];
    
    [self doSocialLogin];
    
}

- (IBAction)actionLoginViaWithTwitter:(id)sender {
    [self showLoadingView];

    [[Twitter sharedInstance] startWithConsumerKey:@"RNpMrK6DdNYwwPhKDgSZhhExz" consumerSecret:@"lTGBnNZTrwQCSxi75TNjETepOFnQ4VtXDrQDZaaT4pknb5gYMl"];
    [Fabric with:@[[Twitter sharedInstance]]];

    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        if (session) {
            NSLog(@"signed in as %@", [session userName]);
            
            [[[Twitter sharedInstance] APIClient] loadUserWithID:[session userID]
                                                      completion:^(TWTRUser *user,
                                                                   NSError *error)
             {
                 
                   // handle the response or error
                 if (![error isEqual:nil]) {
                     NSLog(@"Twitter info   -> user = %@ ",user);
                     NSString *urlString = [[NSString alloc]initWithString:user.profileImageLargeURL];
                     NSURL *url = [[NSURL alloc]initWithString:urlString];
                     NSData *pullTwitterPP = [[NSData alloc]initWithContentsOfURL:url];
                     
                     UIImage *profImage = [UIImage imageWithData:pullTwitterPP];
                     
                     [self usersShow:user.userID accessToken:session.authToken profileImageLink:urlString username:[session userName]];
                     
                 } else {
                     [self hideLoadingView];
                     
//                     [g_Delegate AlertWithCancel_btn:[NSString stringWithFormat:@"Twitter error getting profile : %@", [error localizedDescription]]];
                 }
             }];
        } else {
            NSLog(@"error: %@", [error localizedDescription]);

            [self hideLoadingView];
        }
    }];
}

-(void)requestUserEmail
{
    if ([[Twitter sharedInstance] session]) {
        
        TWTRShareEmailViewController *shareEmailViewController =
        [[TWTRShareEmailViewController alloc]
         initWithCompletion:^(NSString *email, NSError *error) {
             NSLog(@"Email %@ | Error: %@", email, error);
         }];
        
        [self presentViewController:shareEmailViewController
                           animated:YES
                         completion:nil];
    } else {
        // Handle user not signed in (e.g. attempt to log in or show an alert)
    }
}

-(void)usersShow:(NSString *)userID accessToken:(NSString *) strAccessToken profileImageLink:(NSString *) strProfileLink username:(NSString *) strTwitterName
{
    NSString *statusesShowEndpoint = @"https://api.twitter.com/1.1/users/show.json";
    NSDictionary *params = @{@"user_id": userID};
    
    NSError *clientError;
    NSURLRequest *request = [[[Twitter sharedInstance] APIClient]
                             URLRequestWithMethod:@"GET"
                             URL:statusesShowEndpoint
                             parameters:params
                             error:&clientError];
    
    if (request) {
        [[[Twitter sharedInstance] APIClient]
         sendTwitterRequest:request
         completion:^(NSURLResponse *response,
                      NSData *data,
                      NSError *connectionError) {
             if (data) {
                 // handle the response data e.g.
                 [self hideLoadingView];
                 
                 NSError *jsonError;
                 NSDictionary *json = [NSJSONSerialization
                                       JSONObjectWithData:data
                                       options:0
                                       error:&jsonError];
                 NSLog(@"%@",[json description]);
                 
                 dictFBUserInfo = nil;
                 NSArray* arrayName = [[json valueForKey:@"name"] componentsSeparatedByString:@" "];
                 
                 dictFBUserInfo = [[NSMutableDictionary alloc] init];
                 [dictFBUserInfo setValue:strTwitterName forKey:@"username"];
                 [dictFBUserInfo setValue:userID forKey:@"id"];
                 [dictFBUserInfo setValue:strAccessToken forKey:@"accessToken"];
                 [dictFBUserInfo setValue:[arrayName firstObject] forKey:@"firstname"];
                 [dictFBUserInfo setValue:[arrayName lastObject] forKey:@"lastname"];
                 [dictFBUserInfo setValue:@"" forKey:@"gender"];
                 [dictFBUserInfo setValue:@"" forKey:@"email"];
                 [dictFBUserInfo setValue:strProfileLink forKey:@"picture"];
                 
                 NSMutableDictionary *dictSessionInfo = [[NSMutableDictionary alloc] init];
                 
                 [dictSessionInfo setValue:userID forKey:@"social_id"];
                 [dictSessionInfo setValue:g_Delegate.m_strDeviceToken forKey:@"pushId"];
                 [dictSessionInfo setValue:@"userByTwitter" forKey:@"loginmode"];
                 
                 g_Delegate.m_socialSessionInfo = [dictSessionInfo mutableCopy];
                 g_Delegate.m_nRegisterMode = TWITTER_REGISTER;

                 [[UserDefaultHelper sharedObject] setFacebookLoginRequest:dictSessionInfo];
                 
                 [self doSocialLogin];
                 
//                 [self requestUserEmail];
             }
             else {
                 [self hideLoadingView];
                 NSLog(@"Error code: %ld Error description: %@", (long)[connectionError code], [connectionError localizedDescription]);
             }
         }];
    }
    else {
        [self hideLoadingView];
        NSLog(@"Error: %@", clientError);
    }
}

- (IBAction)actionForgotPassword:(id)sender {
    return;
    
    if (self.m_txtUserName.text.length == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please input your email address!"];
        return;
    }
    
    if (![[Utils sharedObject] validateEmail:self.m_txtUserName.text])
    {
        [g_Delegate AlertWithCancel_btn:@"Please input correct email address!"];
        return;
    }
    
    [self showLoadingView];
    
    nRequestMode = FORGOT_PASSWORD;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"account/forgot_password"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setPostValue:self.m_txtUserName.text forKey:@"email"];
    
    [request setRequestMethod:@"POST"];

    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
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
            if ([[dictResponse valueForKey:@"message"] rangeOfString:@"not exist"].location != NSNotFound)
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                SignUpViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"signupview"];
                viewCon.m_dictFBInfo = dictFBUserInfo;
                viewCon.m_bCreateFBUser = true;
//                g_Delegate.m_nRegisterMode = SOCIAL_REGISTER;
                
                [self.navigationController pushViewController:viewCon animated:YES];

            }
            else
                [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
        }

    }
    
    if (nRequestMode == FORGOT_PASSWORD)
    {
        if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
        {
            [g_Delegate AlertWithCancel_btn:@"Please check your email."];
            return;
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
            if ([[dictResponse valueForKey:@"message"] rangeOfString:@"not exist"].location != NSNotFound){
                [g_Delegate AlertWithCancel_btn:@"There is no account with this username and password!"];
            }
            else if([[dictResponse valueForKey:@"message"] rangeOfString:@"with this username!"].location != NSNotFound){
                [g_Delegate AlertWithCancel_btn:@"Incorrect password"];
            }
            else
                [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

@end
