//
//  FriendProfileViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelfieCustomView.h"

#define GET_PROFILE_REQUEST         10
#define REPORT_PHOTO_REQUEST        11
#define REPORT_USER_REQUEST         12

@interface FriendProfileViewController : UIViewController<SelfieCustomViewDelegate, UIGestureRecognizerDelegate>
{
    int nRequestMode;
    
    bool bClickedPopUp;
    
    NSMutableArray* arrayPhotoViews;
    NSMutableArray* arrayPhotos;
    
    NSDictionary* dictUserInfo;
    
    int nSelectedPhotoIdx;
}
@property (weak, nonatomic) IBOutlet UIButton *m_btnActionBack;
- (IBAction)actionBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *m_btnViewMode;
- (IBAction)actionViewModePhotos:(id)sender;

@property (nonatomic, strong) NSString* m_strUserName;
@property (nonatomic, strong) NSString* m_strUserId;
@property (nonatomic, strong) NSString* m_strUserPhotoUrl;

@property (weak, nonatomic) IBOutlet UIImageView *m_bgImageView;

@property (weak, nonatomic) IBOutlet UIView *m_viewUserInfo;
@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblUserName;
@property (weak, nonatomic) IBOutlet UIImageView *m_imageLocationMark;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLocation;
@property (weak, nonatomic) IBOutlet UIButton *m_btnReport;
- (IBAction)actionReport:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewPopup;
- (IBAction)actionViewListMode:(id)sender;
- (IBAction)actionViewGridMode:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;



@end
