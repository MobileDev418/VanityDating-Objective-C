//
//  ChatListViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "ChatListViewController.h"
#import "Global.h"
#import "FriendProfileViewController.h"
#import "MessageController.h"

@interface ChatListViewController ()

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"GO DATE";

    arrResult = [[NSMutableArray alloc] init];
    arraySearch = [[NSMutableArray alloc] init];
    
    self.m_txtSearch.delegate = self;
    self.m_txtSearch.returnKeyType = UIReturnKeySearch;
    [self.m_txtSearch addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventEditingChanged];

    [self modifyClearButtonWithImage];
    
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    
    self.m_tableView.tableFooterView = [[UIView alloc] init];
    
    nOffset = 0;
    bPossibleLoadNext = true;
    
    __weak ChatListViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    self.m_txtSearch.text = @"";
    bSearchMode = false;
    
    g_Delegate.m_curChatListViewCon = self;
    
    [self getFriends];

}

- (void) loadBelowMore
{
    if (bSearchMode)
        return;
    
    if (bPossibleLoadNext)
        [self getFriends];
    else
        [self.m_tableView.infiniteScrollingView stopAnimating];
}

- (void)modifyClearButtonWithImage{
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome timesCircleOIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imageClose = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:imageClose forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    [button addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    self.m_txtSearch.rightView = button;
    self.m_txtSearch.rightViewMode = UITextFieldViewModeWhileEditing;
}

-(void)clear:(id)sender{
    self.m_txtSearch.text = @"";
    
    bSearchMode = false;
    
    arraySearch = [arrResult mutableCopy];

    [self.m_tableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated
{
    g_Delegate.m_curChatListViewCon = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    g_Delegate.m_curChatListViewCon = nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

- (void) getFriends
{
    [self showLoadingView];
    
    nRequestMode = GET_FRIENDS_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"chat/getFriends"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:[NSString stringWithFormat:@"%d", nOffset] forKey:@"offset"];
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (void) doSearch
{
    [arraySearch removeAllObjects];
    
    if (self.m_txtSearch.text.length == 0)
    {
        bSearchMode = false;
 
        arraySearch = [arrResult mutableCopy];
    }
    else
    {
        bSearchMode = true;

        for (int nIdx = 0; nIdx < arrResult.count; nIdx++)
        {
            NSDictionary* dictInfo = [arrResult objectAtIndex:nIdx];
            if ([[[dictInfo valueForKey:@"username"] lowercaseString] rangeOfString:[self.m_txtSearch.text lowercaseString]].location != NSNotFound)
                [arraySearch addObject:dictInfo];
        }
    }
    
    [self.m_tableView reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self doSearch];
    
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.m_txtSearch.placeholder = @"";
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (textField.text.length == 0)
        self.m_txtSearch.placeholder = @"Search";
    
    return YES;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtSearch resignFirstResponder];
}

- (void) deleteChatUser:(NSString *) strId;
{
    [self showLoadingView];
    
    nRequestMode = DELETE_CHAT_USER;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"chat/delete_chat_user"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    [request setPostValue:strId forKey:@"sel_id"];
    
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];

}

#pragma mark Swipe Delegate
- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    [super setEditing:editing animated:animated];
}

-(void) deleteFolderCell:(NSIndexPath *) indexPath
{
    //delete
    NSDictionary* dictInfo = [arraySearch objectAtIndex:indexPath.row];
    [self deleteChatUser:[dictInfo valueForKey:@"account_id"]];

    [arraySearch removeObjectAtIndex:indexPath.row];
    
    [self.m_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
{
    return YES;
}

-(NSArray*) swipeTableCell:(MGSwipeTableCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{
    swipeSettings.transition = MGSwipeTransition3D;
    expansionSettings.buttonIndex = 0;
    
    __weak ChatListViewController * me = self;
    
    if (direction == MGSwipeDirectionRightToLeft) {
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        
        CGFloat padding = 30;
        
        MGSwipeButton * trash = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"chat_delete_icon.png"] backgroundColor:NAVI_COLOR padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            NSIndexPath * indexPath = [me.m_tableView indexPathForCell:sender];
            
            [me deleteFolderCell:indexPath];
            return NO; //don't autohide to improve delete animation
        }];
        
        return @[trash];
    }
    
    return nil;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arraySearch.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"chatlistcell";
    
    MGSwipeTableCell *cell = (MGSwipeTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[MGSwipeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary* dictUserInfo = [arraySearch objectAtIndex:indexPath.row];
    
    cell.delegate = self;
    UIImageView* imageView = (UIImageView *)[cell viewWithTag:10];
    UILabel* lblName = (UILabel *)[cell viewWithTag:11];
    UILabel* lblContent = (UILabel *)[cell viewWithTag:12];
    
    imageView.image = [UIImage imageNamed:DEFAULT_AVATAR_IMAGE];
    imageView.layer.cornerRadius = imageView.frame.size.height / 2;
    imageView.layer.borderWidth = 4.f;
    imageView.layer.borderColor = CORNER_BORDER_COLOR.CGColor;
    imageView.clipsToBounds = YES;
    
    lblName.text = [dictUserInfo valueForKey:@"username"];
    lblContent.text = [[Utils sharedObject] checkAvaiablityForString:[dictUserInfo valueForKey:@"last_chat"]];
    
    [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@", RESOURCE_URL, [dictUserInfo valueForKey:@"photo_url"]] imageView:imageView];

    int count = 0;
    for (int nIdx = g_Delegate.m_arrMissedMessages.count - 1; nIdx >=0; nIdx--)
    {
        NSDictionary* dictInfo = [g_Delegate.m_arrMissedMessages objectAtIndex:nIdx];
        
        if ([[dictInfo valueForKey:@"sender_id"] isEqualToString:[dictUserInfo valueForKey:@"account_id"]] && [[dictInfo valueForKey:@"checked"] integerValue] == 0)
            count++;
    }
    
    // Count > 0, show count
    if (count > 0) {
        
        // Create label
        CGFloat fontSize = 14;
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont fontWithName:MAIN_FONT_NAME size:fontSize];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.backgroundColor = [UIColor redColor];
        
        // Add count to label and size to fit
        label.text = [NSString stringWithFormat:@"%@", @(count)];
        [label sizeToFit];
        
        // Adjust frame to be square for single digits or elliptical for numbers > 9
        CGRect frame = label.frame;
        frame.size.height += (int)(0.4*fontSize);
        frame.size.width = (count <= 9) ? frame.size.height : frame.size.width + (int)fontSize;
        label.frame = frame;
        
        // Set radius and clip to bounds
        label.layer.cornerRadius = frame.size.height/2.0;
        label.clipsToBounds = true;
        
        // Show label in accessory view and remove disclosure
        cell.accessoryView = label;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Count = 0, show disclosure
    else {
        cell.accessoryView = nil;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
   return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary* dictUserInfo = [arraySearch objectAtIndex:indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    MessageController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"messageview"];
    viewCon.m_strChatUserName  = [dictUserInfo valueForKey:@"username"];
    viewCon.m_strChatUserId = [dictUserInfo valueForKey:@"account_id"];
    viewCon.m_strChatUserImagePath = [dictUserInfo valueForKey:@"photo_url"];
    
    [self.navigationController pushViewController:viewCon animated:YES];

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

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self.m_tableView.infiniteScrollingView stopAnimating];

    [self hideLoadingView];
    
    NSString *receivedData = [request responseString];
    NSDictionary* dictResponse = [receivedData JSONValue];
    if (dictResponse == nil)
    {
        if (nRequestMode == GET_FRIENDS_REQUEST)
            bPossibleLoadNext = true;

        [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
        return;
    }

    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        [arrResult removeAllObjects];
        if (nRequestMode == GET_FRIENDS_REQUEST)
        {
            arrResult = [dictResponse valueForKey:@"users"];
            [arraySearch addObjectsFromArray:[arrResult mutableCopy]];
            
            bPossibleLoadNext = false;
            if (arrResult.count == MAX_EVENT_NUM)
            {
                bPossibleLoadNext = true;
                nOffset++;
            }

            [self.m_tableView reloadData];
        }
        
        if (nRequestMode == DELETE_CHAT_USER)
        {
            [g_Delegate AlertSuccess:@"Deleted chat user successfully."];
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
    [self.m_tableView.infiniteScrollingView stopAnimating];
    
    bPossibleLoadNext = true;

    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

@end
