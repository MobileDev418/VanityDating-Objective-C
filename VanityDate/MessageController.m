//
//  MessageController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.

#import "MessageController.h"
#import "DAKeyboardControl.h"

#import "Message.h"
#import "MessageCell.h"
#import "MessageGateway.h"
#import "Global.h"
#import "FriendProfileViewController.h"
#import "HomeViewController.h"

@interface MessageController() <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MessageGatewayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *m_btnSend;

@property (assign, nonatomic) NSInteger changeSender;
@property (strong, nonatomic) MessageGateway *gateway;
@property (weak, nonatomic) IBOutlet UIImageView *m_chatUserImageView;
@property (weak, nonatomic) IBOutlet UILabel *m_lblChatUserName;

@end

@implementation MessageController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.frame = [[UIScreen mainScreen] bounds];
    
    self.m_bgImageView.image = [[Utils sharedObject] rn_boxblurImageWithBlur:BLUR_DEGREE exclusionPath:nil image:[UIImage imageNamed:@"upload_bg.png"]];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self setTableView];
    [self loadMissedChatHistory];
    self.textField.delegate = self;
    
    self.navigationItem.title = self.m_strChatUserName;
    self.m_lblChatUserName.text = self.m_strChatUserName;

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32.f, 32.f)];
    imageView.image = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, self.m_strChatUserImagePath] imageView:imageView];

    imageView.layer.cornerRadius = 16.f;
    imageView.layer.borderColor = MAIN_COLOR.CGColor;
    imageView.layer.borderWidth = 2.f;
    imageView.clipsToBounds = YES;
    
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureForImage = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGestureForImage.numberOfTapsRequired = 1;
    [tapGestureForImage setDelegate:self];
    [imageView addGestureRecognizer:tapGestureForImage];

    FAKFontAwesome *sendIcon = [FAKFontAwesome paperPlaneOIconWithSize:ICON_SIZE];
    [sendIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *sendImage = [sendIcon imageWithSize:CGSizeMake(ICON_SIZE, ICON_SIZE)];
    [self.m_btnSend setImage:sendImage forState:UIControlStateNormal];

    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    self.m_chatUserImageView.image = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE];
    [self updateUI];
}

- (void) backToMainView
{
    [g_Delegate.m_curHomeViewCon showMenuTabView];

    [self.navigationController popViewControllerAnimated:YES];
}

- (void) tapGesture:(UITapGestureRecognizer *)gesture
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FriendProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"friendprofileview"];
    viewCon.m_strUserName = self.m_strChatUserName;
    viewCon.m_strUserId = self.m_strChatUserId;
    viewCon.m_strUserPhotoUrl = self.m_strChatUserImagePath;
    
    [self.navigationController pushViewController:viewCon animated:YES];

}

- (void) viewWillAppear:(BOOL)animated
{
    g_Delegate.m_curMessageViewCon = self;
 
    self.navigationController.navigationBar.translucent = NO;
    [g_Delegate.m_curHomeViewCon hideMenuTabView];
    
    [self updateUI];
}


- (void) updateUI
{
    if (self.m_chatUserImageView.frame.size.width > self.m_chatUserImageView.frame.size.height)
    {
        self.m_chatUserImageView.frame = CGRectMake(0, 0, self.m_chatUserImageView.frame.size.height, self.m_chatUserImageView.frame.size.height);
        self.m_chatUserImageView.layer.cornerRadius = self.m_chatUserImageView.frame.size.height / 2.f;
    }
    else
    {
        self.m_chatUserImageView.frame = CGRectMake(0, 0, self.m_chatUserImageView.frame.size.width, self.m_chatUserImageView.frame.size.width);
        self.m_chatUserImageView.layer.cornerRadius = self.m_chatUserImageView.frame.size.width / 2.f;
    }
    
    self.m_chatUserImageView.layer.borderWidth = 3.f;
    self.m_chatUserImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.m_chatUserImageView.clipsToBounds = YES;
    
    self.m_chatUserImageView.center = CGPointMake(self.view.frame.size.width / 2, self.m_chatUserImageView.center.y);
    
    [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, self.m_strChatUserImagePath] imageView:self.m_chatUserImageView];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateUI];
    
    UIView *toolBar = _toolBar;
    UITableView *tableView = _tableView;
    
    __weak MessageController *weakSelf = self;

    self.view.keyboardTriggerOffset = toolBar.frame.size.height;
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        
         /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        
        CGRect toolBarFrame = weakSelf.toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        weakSelf.toolBar.frame = toolBarFrame;
        
        CGRect tableViewFrame = weakSelf.tableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y - weakSelf.m_viewUserInfo.frame.origin.y - weakSelf.m_viewUserInfo.frame.size.height;
        weakSelf.tableView.frame = tableViewFrame;
        
        if ([weakSelf.messageArray numberOfSections] >= 1)
        {
            [weakSelf.tableView scrollToRowAtIndexPath:[weakSelf.messageArray indexPathForLastMessage]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
    }constraintBasedActionHandler:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self updateUI];
    
    g_Delegate.m_curMessageViewCon = nil;
    
    if (curRequest)
    {
        [curRequest setDelegate:nil];
        curRequest = nil;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view removeKeyboardControl];
}

-(void)loadChatHistory
{
    NSMutableArray *array = [NSMutableArray new];
    
    int nIdx = 0;
    bool bEndOfMessage = false;
    if (g_Delegate.m_arrMissedMessages.count == 0)
        bEndOfMessage = true;
    
    while (!bEndOfMessage)
    {
        NSLog(@"%d", nIdx);
        
        NSDictionary* dictInfo = [g_Delegate.m_arrMissedMessages objectAtIndex:nIdx];
        
        if ( (([[dictInfo valueForKey:@"sender_id"] isEqualToString:[g_Delegate.m_curUserInfo valueForKey:@"id"]]) && ([[dictInfo valueForKey:@"receiver_id"] isEqualToString:self.m_strChatUserId]) ) || ( (([[dictInfo valueForKey:@"receiver_id"] isEqualToString:[g_Delegate.m_curUserInfo valueForKey:@"id"]]) && ([[dictInfo valueForKey:@"sender_id"] isEqualToString:self.m_strChatUserId]) )) )
        {
            Message *message = [[Message alloc] init];
            
            NSString* strRecvMsg =  [dictInfo valueForKey:@"message"];
            strRecvMsg = [strRecvMsg stringByReplacingOccurrencesOfString:@"\\\\" withString:@"\\"];
            
            NSData *data = [strRecvMsg dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
            
            message.text = goodValue;
            
            if ([[dictInfo valueForKey:@"sender_id"] isEqualToString:[g_Delegate.m_curUserInfo valueForKey:@"id"]])
                message.sender = MessageSenderMyself;
            else
                message.sender = MessageSenderSomeone;
            
            message.sent = [[NSDate date] dateByAddingTimeInterval:-1 * [[dictInfo valueForKey:@"created"] floatValue]];
            message.status = MessageStatusRead;
            if (message.sender == MessageSenderMyself)
                message.imagepath = g_Delegate.m_strCurUserProfileImage;
            else
                message.imagepath = self.m_strChatUserImagePath;
            
            [array addObject:message];
            
            [self checkMessage:[dictInfo valueForKey:@"chat_id"]];
            [g_Delegate.m_arrMissedMessages removeObjectAtIndex:nIdx];
            
            if (g_Delegate.m_arrMissedMessages.count == 0 || nIdx > g_Delegate.m_arrMissedMessages.count - 1)
                bEndOfMessage = true;
            
            continue;
        }
        
        nIdx++;
        if (nIdx > g_Delegate.m_arrMissedMessages.count - 1)
        {
            bEndOfMessage = true;
        }
    }
    
    [self.messageArray addMessages:array];

    [g_Delegate showBadgeNumIntoHomeView];
    
    [self.tableView reloadData];

    /*
    [self showLoadingView];
    
    nRequestMode = GET_CHAT_HISTORY_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"chat/getChatHistory"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setPostValue:self.m_strChatUserId forKey:@"sender_id"];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
     */
    
}

- (void) loadMissedChatHistory
{
    [self showLoadingView];
    
    nRequestMode = GET_CHAT_HISTORY_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"chat/getChatHistory"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setPostValue:self.m_strChatUserId forKey:@"sender_id"];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

-(void)setTableView
{
    self.messageArray = [[MessageArray alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f,self.view.frame.size.width, 30.0f)];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
-(void)scrollToBottomTableView
{
    if (self.tableView.contentOffset.y > self.tableView.frame.size.height)
    {
        [self.tableView scrollToRowAtIndexPath:[self.messageArray indexPathForLastMessage]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Action
- (void) sendMessage
{
    [self showLoadingView];
    
    nRequestMode = SEND_MESSAEG_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"chat/sendMessage"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    NSData *data = [strSendMessageText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    goodValue = [goodValue stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];

    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setPostValue:goodValue forKey:@"message"];
    [request setPostValue:self.m_strChatUserId forKey:@"receiver_id"];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    curRequest = request;

    [request startAsynchronous];

}

- (IBAction)send:(UIButton *)button
{
    //Verify Empty Text
    strSendMessageText = self.textField.text;//[self.textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([strSendMessageText isEqualToString:@""]) return;
    
    [self sendMessage];
}

- (void) checkMessage:(NSString *) strChatId
{
    nRequestMode = CHECK_RECEIVE_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"chat/check_message"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:nil];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setPostValue:strChatId forKey:@"chat_id"];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    curRequest = request;
    
    [request startAsynchronous];
    
}

- (void) showReceiveMessages:(NSMutableArray *) arrReceiveMsgs
{
    for (int nIdx = 0; nIdx < arrReceiveMsgs.count; nIdx++)
    {
        NSDictionary* dictMsgInfo = [arrReceiveMsgs objectAtIndex:nIdx];
        
        Message *message = [[Message alloc] init];
        message.text = [dictMsgInfo valueForKey:@"message"];
        message.sender = MessageSenderSomeone;
        message.sent = [NSDate date];
        message.imagepath = self.m_strChatUserImagePath;
        
        [self.messageArray addMessage:message];
        NSIndexPath *indexPath = [self.messageArray indexPathForMessage:message];
        
        [self.tableView beginUpdates];
        
        if ([self.messageArray numberOfMessagesInSection:indexPath.section] == 1)
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        [self.tableView scrollToRowAtIndexPath:[self.messageArray indexPathForLastMessage]
                              atScrollPosition:UITableViewScrollPositionBottom animated:YES];

        [self checkMessage:[dictMsgInfo valueForKey:@"chat_id"]];
    }
}

- (IBAction)userDidTapScreen:(id)sender
{
    [self.textField resignFirstResponder];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.messageArray numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messageArray numberOfMessagesInSection:section];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MessageCell";
    MessageCell *cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Message *message = [self.messageArray messageAtIndexPath:indexPath];
    cell.message = message;

    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageCell *cell = (MessageCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell?cell.height:44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 40);
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor clearColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:MAIN_FONT_NAME size:20.0];
    [label sizeToFit];
    label.center = view.center;
    label.font = [UIFont fontWithName:MAIN_FONT_NAME size:13.0];
    label.backgroundColor = [UIColor colorWithRed:207/255.0 green:220/255.0 blue:252.0/255.0 alpha:1];
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
    label.autoresizingMask = UIViewAutoresizingNone;
    [view addSubview:label];
    
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.messageArray titleForSection:section];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self performSelector:@selector(scrollToBottomTableView) withObject:nil afterDelay:.3];
}

#pragma mark - MessageGateway

-(void)gatewayDidUpdateStatusForMessage:(Message *)message
{
    NSIndexPath *indexPath = [self.messageArray indexPathForMessage:message];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
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
    
    curRequest = nil;
    
    NSString *receivedData = [request responseString];
    NSDictionary* dictResponse = [receivedData JSONValue];
    if (dictResponse == nil)
    {
        [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
        return;
    }
    
    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        if (nRequestMode == GET_CHAT_HISTORY_REQUEST)
        {
            [g_Delegate.m_arrMissedMessages removeAllObjects];
            g_Delegate.m_arrMissedMessages = [dictResponse valueForKey:@"result"];
            
            [g_Delegate showBadgeNumIntoHomeView];

            [self loadChatHistory];
            
            return;
        }
        
        if (nRequestMode == CHECK_RECEIVE_REQUEST)
        {
            NSLog(@"checked message");
        }
        
        if (nRequestMode == SEND_MESSAEG_REQUEST)
        {
            //Add Message to MessageArray
            Message *message = [[Message alloc] init];
            message.text = strSendMessageText;
            message.sender = MessageSenderMyself;
            message.sent = [NSDate date];
            message.imagepath = g_Delegate.m_strCurUserProfileImage;
            
            [self.messageArray addMessage:message];
            NSIndexPath *indexPath = [self.messageArray indexPathForMessage:message];
            
            [self.tableView beginUpdates];
            
            if ([self.messageArray numberOfMessagesInSection:indexPath.section] == 1)
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
            
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:[self.messageArray indexPathForLastMessage]
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
            self.textField.text = @"";
            
            if (!_gateway)
            {
                _gateway = [[MessageGateway alloc] init];
                _gateway.delegate = self;
            }
            [_gateway sendMessage:message];

            return;
        }
    }
    else
    {
        [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    curRequest = nil;

    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

@end
