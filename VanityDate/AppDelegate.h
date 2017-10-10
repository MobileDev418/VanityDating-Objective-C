//
//  AppDelegate.h
//  VanityDate
//
//  Created by iOSDevStar on 7/5/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class HomeViewController;
@class MessageController;
@class ChatListViewController;

#define LOCATION_UPDATE_REQUEST         10
#define CHAT_HISTORY_REQUEST            11

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    int nRequestMode;
    bool bJustBecomeActive;
    bool bAppInBackground;
    
    CLLocationManager *locationManager;
    
    NSTimer* timderUpdateLocation;
    
    
}

@property (assign, nonatomic) bool bLoadAds;

@property (nonatomic, strong) NSMutableArray* m_arrMissedMessages;


@property (nonatomic, strong) MessageController *m_curMessageViewCon;
@property (nonatomic, strong) ChatListViewController* m_curChatListViewCon;

@property (nonatomic, strong) NSMutableArray* m_arrCategories;
@property (nonatomic, strong) NSMutableArray* m_arrSubCategories;

@property (nonatomic, strong) NSMutableDictionary* m_curUserInfo;
@property (nonatomic, strong) NSString* m_strCurUserProfileImage;

@property (nonatomic, strong) HomeViewController *m_curHomeViewCon;

@property (nonatomic, assign) bool m_bRegisterSuccess;
@property (nonatomic, assign) int m_nRegisterMode;
@property (nonatomic, strong) NSMutableDictionary *m_socialSessionInfo;

@property (nonatomic, assign) bool m_bLogin;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSString* m_strAccessToken;
@property (nonatomic, strong) NSString* m_strAccessDeviceId;

@property (nonatomic, strong) NSString* m_strDeviceToken;
@property (nonatomic, strong) NSString* m_strLatitude;
@property (nonatomic, strong) NSString* m_strLongitude;

@property (nonatomic, strong) NSMutableDictionary* m_dictCurrentUser;

-(void)AlertWithCancel_btn:(NSString*)AlertMessage;
- (void) AlertSuccess:(NSString *) AlertMessage;
- (void) AlertFailure:(NSString *) AlertMessage;

- (void) loadMissedChatHistory:(bool) bLoadingView;
- (void) showBadgeNumIntoHomeView;

@end

