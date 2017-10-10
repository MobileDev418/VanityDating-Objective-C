//
//  Global.h
//  Education
//
//  Created by QingLong on 18/03/15.
//  Copyright (c) 2015 QingLong. All rights reserved.
//

#ifndef Education_Global_h
#define Education_Global_h

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import <Foundation/Foundation.h>
#import "FontAwesomeKit.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+Utility.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "UserDefaultHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "FacebookUtility.h"
#import "Utils.h"
#import "SVPullToRefresh.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "HMSegmentedControl.h"
#import "DAKeyboardControl.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapPinAnnotation.h"
#import "MGSwipeButton.h"
#import "MGSwipeTableCell.h"
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"
#import "JSBadgeView.h"
#import "NMRangeSlider.h"
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>

#define APP_FULL_NAME           @"Vanity Dating"

#define DOCUMENTS_PATH          [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define MENU_TAB_HEIGHT         70.f
#define BLUR_DEGREE             0.5f

#define ICON_SIZE               24
#define NAVI_ICON_SIZE          24
#define TAB_ICON_SIZE           36
#define CLOSE_BUTTON_SIZE       32

#define LOGIN_REQUEST               90
#define SOCIAL_LOGIN_REQUEST        91
#define FORGOT_PASSWORD             92
#define SIGNUP_REQUEST              93

#define EMAIL_REGISTER                  102
#define SOCIAL_REGISTER                 103
#define FACEBOOK_REGISTER               104
#define TWITTER_REGISTER                105

#define INDICATOR_ANIMATION     0.2f

#define MAX_EVENT_NUM           15

#define MAIN_COLOR              [UIColor colorWithRed:118.f/255.f green:118.f/255.f blue:114.f/255.f alpha:0.6f]
#define NAVI_COLOR              [UIColor colorWithRed:37.f/255.f green:37.f/255.f blue:37.f/255.f alpha:1.0f]
#define ACTIVATE_COLOR          [UIColor colorWithRed:245.f/255.f green:124.f/255.f blue:0.f/255.f alpha:1.0f]
#define OTHER_EVENT_COLOR       [UIColor colorWithRed:106.f/255.f green:181.f/255.f blue:69.f/255.f alpha:1.f]

#define BG_COLOR                [UIColor colorWithRed:46.f/255.f green:46.f/255.f blue:46.f/255.f alpha:1.0f]
#define OTHER_BG_COLOR          [UIColor colorWithRed:93.f/255.f green:93.f/255.f blue:93.f/255.f alpha:0.6f]

#define TEXTFIELD_BG_COLOR      [UIColor colorWithRed:34.f/255.f green:34.f/255.f blue:34.f/255.f alpha:1.0f]

#define CORNER_BORDER_COLOR     [UIColor colorWithRed:67.f/255.f green:67.f/255.f blue:67.f/255.f alpha:1.0f]

#define SEARCH_SETTING_COLOR    [UIColor colorWithRed:88.f/255.f green:88.f/255.f blue:86.f/255.f alpha:1.0f]

#define DISABLE_COLOR           [UIColor grayColor]

#define MAIN_FONT_NAME          @"Avenir-Book"
#define MAIN_BOLD_FONT_NAME     @"Avenir-Black"

/*
#define SERVER_URL              @"http://vanitydating.com/developer/api/"
#define RESOURCE_URL            @"http://vanitydating.com/developer/images/photo/"
#define CATEGORY_IMAGEA_URL     @"http://vanitydating.com/developer/images/event/"
 */

#define SERVER_URL              @"http://vanitydating.com/api/"
#define RESOURCE_URL            @"http://vanitydating.com/images/photo/"
#define CATEGORY_IMAGEA_URL     @"http://vanitydating.com/images/event/"
#define ADS_IMAGE_URL           @"http://vanitydating.com/images/ads/"
/*
#define SERVER_URL              @"http://192.168.1.157/vanity/api/"
#define RESOURCE_URL            @"http://192.168.1.157/vanity/images/photo/"
#define CATEGORY_IMAGEA_URL     @"http://192.168.1.157/vanity/images/event/"
 */


#define CORNER_RADIUS           3

#define MAX_TITLE               50
#define MAX_DESCRITPION         500

#define SUCCESS_STRING          @"Success"
#define FAILTURE_STRING         @"Failure"

#define NET_CONNECTION_ERROR    @"The Network connection appears to be offline!"
#define SOMETHING_WRONG         @"Something went wrong!"

#define REFRESH_HEIGHT          (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 120.f:240.f)

#define g_Delegate              ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#define POST_TEXT_PLACEHOLDER   @"Please input something..."

#define TEST_DEVICE_TOKEN       @"SIMULATOR"
#define DEVICE_MODEL            @"ios"

#define CURRENT_LONGITUDE       @"nolocation"
#define CURRENT_LATITUDE        @"nolocation"


#define CURRENT_LONGITUDE       @"125.41914218"
#define CURRENT_LATITUDE        @"43.84631467"


#define DEFAULT_AVATAR_IMAGE    @"default_avatar.png"
#define DEFAULT_SELFIE_IMAGE    @"default_selfie.png"
#define DEFAULT_EVENT_IMAGE     @"default_event.png"

#endif
