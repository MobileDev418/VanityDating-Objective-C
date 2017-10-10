//
//  AppDelegate.m
//  VanityDate
//
//  Created by iOSDevStar on 7/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "AppDelegate.h"
#import "Global.h"
#import "HomeViewController.h"
#import "MessageController.h"
#import "OTNotification.h"
#import "ChatListViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize m_strDeviceToken;
@synthesize m_strLatitude;
@synthesize m_strLongitude;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if([UINavigationBar conformsToProtocol:@protocol(UIAppearanceContainer)]) {
        [UINavigationBar appearance].tintColor = [UIColor whiteColor];
        [UINavigationBar appearance].barTintColor = NAVI_COLOR;
        
        [UINavigationBar appearance].titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                         [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:18.0f], UITextAttributeFont,
                                                                         [UIColor whiteColor], UITextAttributeTextColor,
                                                                         [UIColor grayColor], UITextAttributeTextShadowColor,
                                                                         [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 0.0f)], UITextAttributeTextShadowOffset,
                                                                         nil];

    }
    
    bJustBecomeActive = false;
    bAppInBackground = false;
    
    self.bLoadAds = false;
    
    self.m_bLogin = false;
    
    self.m_curUserInfo = nil;
    self.m_curMessageViewCon = nil;
    
    self.m_arrMissedMessages = [[NSMutableArray alloc] init];
    
    [[UILabel appearanceWhenContainedIn:[UITextField class], nil] setTextColor:[UIColor whiteColor]];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.m_arrCategories = [[NSMutableArray alloc] init];
    self.m_arrSubCategories = [[NSMutableArray alloc] init];
    
    m_strLongitude = CURRENT_LONGITUDE;
    m_strLatitude = CURRENT_LATITUDE;
    
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
        {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    [locationManager startUpdatingLocation];
    
    m_strDeviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"devicetoken"];
    if ([m_strDeviceToken isKindOfClass:[NSNull class]] || m_strDeviceToken == nil)
        m_strDeviceToken = TEST_DEVICE_TOKEN;
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }

    self.m_bLogin = false;
    timderUpdateLocation = [NSTimer timerWithTimeInterval:5.f target:self selector:@selector(updateLocationProc) userInfo:nil repeats:YES];
    
    return YES;
}

- (void) updateLocationProc
{
    if (!self.m_bLogin)
        return;
    
    nRequestMode = LOCATION_UPDATE_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"update/location"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:self.m_strLatitude forKey:@"latitude"];
    [request setPostValue:self.m_strLongitude forKey:@"longitude"];
    
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
        return;
    }
    
    if (nRequestMode == CHAT_HISTORY_REQUEST)
    {
        [self.m_arrMissedMessages removeAllObjects];
        self.m_arrMissedMessages = [dictResponse valueForKey:@"result"];
        
        [self showBadgeNumIntoHomeView];
        
        if (bJustBecomeActive && self.m_curMessageViewCon)
        {
            [self.m_curMessageViewCon loadChatHistory];
        }
        
        if (self.m_curChatListViewCon)
            [self.m_curChatListViewCon.m_tableView reloadData];

        return;
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
}

- (void) showBadgeNumIntoHomeView
{
    [self hideLoadingView];
    
    int nAllMissedMsgCnt = 0;
    for (int nIdx = 0; nIdx < self.m_arrMissedMessages.count; nIdx++)
    {
        NSDictionary* dictInfo = [self.m_arrMissedMessages objectAtIndex:nIdx];
        if ([[dictInfo valueForKey:@"sender_id"] isEqualToString:[g_Delegate.m_curUserInfo valueForKey:@"id"]] || [[dictInfo valueForKey:@"checked"] integerValue] == 1)
            continue;
        
        nAllMissedMsgCnt++;
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:nAllMissedMsgCnt];
    
    [self.m_curHomeViewCon setBadgeNum:nAllMissedMsgCnt];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];

    /*
    m_strLongitude = CURRENT_LONGITUDE;
    m_strLatitude = CURRENT_LATITUDE;
     */

    m_strLongitude = [NSString stringWithFormat:@"%.8f", location.coordinate.longitude];
    m_strLatitude = [NSString stringWithFormat:@"%.8f", location.coordinate.latitude];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    m_strLongitude = CURRENT_LONGITUDE;
    m_strLatitude = CURRENT_LATITUDE;
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        [self AlertWithCancel_btn:@"You have to enable location service in phone settings."];
    }
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"My token is: %@", newToken);
    
    [[NSUserDefaults standardUserDefaults] setValue:newToken forKey:@"devicetoken"];
    m_strDeviceToken = newToken;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.m_strDeviceToken forKey:@"deviceid"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

-(void) appearLocalNotification:(NSString *) strMessage withUserName:(NSString *) strUserName withPhoto:(NSString *) strUserPhoto
{
    NSString* strChatString = [strMessage stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    NSData *data = [strChatString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

    OTNotificationManager *notificationManager = [OTNotificationManager defaultManager];
    OTNotificationMessage *notificationMessage = [[OTNotificationMessage alloc] init];
    notificationMessage.title = strUserName;
    notificationMessage.message = goodValue;
    notificationMessage.showIcon = YES;
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:DEFAULT_AVATAR_IMAGE]];
    [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, strUserPhoto]] placeholderImage:[UIImage imageNamed:DEFAULT_AVATAR_IMAGE] options:SDWebImageRefreshCached completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
     {
         if (image)
         {
             notificationMessage.iconImage = image;
             [notificationManager postNotificationMessage:notificationMessage];
         }
     } usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
}

- (void) showLoadingView
{
    MBProgressHUD *progressHUB = [[MBProgressHUD alloc] initWithView:self.window];
    [self.window addSubview:progressHUB];
    progressHUB.tag = 100;
    
    [progressHUB show:YES];
    
}

- (void) hideLoadingView
{
    MBProgressHUD* progressHUB = (MBProgressHUD *)[self.window viewWithTag:100];
    if (progressHUB)
    {
        [progressHUB hide:YES];
        [progressHUB removeFromSuperview];
        progressHUB = nil;
    }
}

- (void) loadMissedChatHistory:(bool) bLoadingView
{
    if (!self.m_bLogin)
    {
        return;
    }
    
    if (bLoadingView)
    {
        bJustBecomeActive = true;
        [self showLoadingView];
    }
    
    nRequestMode = CHAT_HISTORY_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"chat/getChatHistory"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];

}

- (void) messageProcess:(NSDictionary *) dictInfo
{
    [self.m_curMessageViewCon showReceiveMessages:[NSMutableArray arrayWithObject:dictInfo]];

}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
    application.applicationIconBadgeNumber = 1;

    NSDictionary* dictInfo = [userInfo valueForKey:@"aps"];
    
    if (![[dictInfo valueForKey:@"type"] isEqualToString:@"message"])
        return;
    
    NSString* strChatString = [dictInfo valueForKey:@"alert"];
    strChatString = [strChatString stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
    NSData *data = [strChatString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];

    NSMutableDictionary* dictMsgInfoForLocal = [[NSMutableDictionary alloc] init];
    [dictMsgInfoForLocal setValue:@"0" forKey:@"created"];
    [dictMsgInfoForLocal setValue:[dictInfo valueForKey:@"sender_id"] forKey:@"sender_id"];
    [dictMsgInfoForLocal setValue:[dictInfo valueForKey:@"receiver_id"] forKey:@"receiver_id"];
    [dictMsgInfoForLocal setValue:[dictInfo valueForKey:@"alert"] forKey:@"message"];
    [dictMsgInfoForLocal setValue:[dictInfo valueForKey:@"chat_id"] forKey:@"chat_id"];
    [dictMsgInfoForLocal setValue:@"0" forKey:@"checked"];
    
    if ( application.applicationState == UIApplicationStateActive)
    {
        if (self.m_curMessageViewCon)
        {
            if ([self.m_curMessageViewCon.m_strChatUserName isEqualToString:[dictInfo valueForKey:@"username"]])
            {
                [self.m_curMessageViewCon showReceiveMessages:[NSMutableArray arrayWithObject:dictMsgInfoForLocal]];
                
                return;
            }
            else
            {
                [self appearLocalNotification:[dictInfo valueForKey:@"alert"] withUserName:[dictInfo valueForKey:@"username"] withPhoto:[dictInfo valueForKey:@"photo_url"]];
                
                [self.m_arrMissedMessages addObject:dictMsgInfoForLocal];
            }
        }
        else
        {
            [self appearLocalNotification:[dictInfo valueForKey:@"alert"] withUserName:[dictInfo valueForKey:@"username"] withPhoto:[dictInfo valueForKey:@"photo_url"]];

            [self.m_arrMissedMessages addObject:dictMsgInfoForLocal];
        }

        if (self.m_curChatListViewCon)
            [self.m_curChatListViewCon.m_tableView reloadData];
        
        [self showBadgeNumIntoHomeView];
    }
    else
    {
        [self loadMissedChatHistory:true];
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    bAppInBackground = true;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if (bAppInBackground)
    {
        bAppInBackground = false;
        if (self.m_bLogin)
            [self loadMissedChatHistory:true];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)AlertWithCancel_btn:(NSString*)AlertMessage
{
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:APP_FULL_NAME message:AlertMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK",nil];
    alertView.tag = 100;
    [alertView show];
}

- (void) AlertSuccess:(NSString *) AlertMessage
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:SUCCESS_STRING message:AlertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.tag = 100;
    [alertView show];
}

- (void) AlertFailure:(NSString *) AlertMessage
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:FAILTURE_STRING message:AlertMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.tag = 100;
    [alertView show];
}

@end
