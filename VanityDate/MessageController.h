//
//  MessageController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.

#import <UIKit/UIKit.h>
#import "MessageArray.h"

#define GET_CHAT_HISTORY_REQUEST    10
#define SEND_MESSAEG_REQUEST        11
#define CHECK_RECEIVE_REQUEST       12

@class ASIFormDataRequest;

@interface MessageController : UIViewController<UIGestureRecognizerDelegate>
{
    int nRequestMode;

    ASIFormDataRequest* curRequest;
    
    NSString* strSendMessageText;
}
@property (weak, nonatomic) IBOutlet UIImageView *m_bgImageView;

@property (weak, nonatomic) IBOutlet UIView *m_viewUserInfo;

@property (strong, nonatomic) MessageArray *messageArray;

@property (nonatomic, strong) NSString* m_strChatUserName;
@property (nonatomic, strong) NSString* m_strChatUserId;
@property (nonatomic, strong) NSString* m_strChatUserImagePath;

- (void) showReceiveMessages:(NSMutableArray *) arrReceiveMsgs;
- (void)loadChatHistory;

@end
