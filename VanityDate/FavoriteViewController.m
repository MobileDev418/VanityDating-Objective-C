//
//  FavoriteViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "FavoriteViewController.h"
#import "Global.h"
#import "FriendProfileViewController.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Favorites";
    
    arrResult = [[NSMutableArray alloc] init];

    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;
    
    self.m_tableView.tableFooterView = [[UIView alloc] init];
    
    nOffset = 0;
    bPossibleLoadNext = true;
    bSearchMode = false;
    
    __weak FavoriteViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    bSearchMode = false;
    
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

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
}

- (void) getFriends
{
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"favorite/getFriends"];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrResult.count;
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
    static NSString *simpleTableIdentifier = @"favoritecell";
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary* dictUserInfo = [arrResult objectAtIndex:indexPath.row];
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSDictionary* dictUserInfo = [arrResult objectAtIndex:indexPath.row];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FriendProfileViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"friendprofileview"];
    viewCon.m_strUserName = [dictUserInfo valueForKey:@"username"];
    viewCon.m_strUserId = [dictUserInfo valueForKey:@"account_id"];
    viewCon.m_strUserPhotoUrl = [dictUserInfo valueForKey:@"photo_url"];
    
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
        bPossibleLoadNext = true;

        [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
        return;
    }
    
    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        [arrResult removeAllObjects];
        [arrResult addObjectsFromArray:[dictResponse valueForKey:@"users"]];
        
        bPossibleLoadNext = false;
        if (arrResult.count == MAX_EVENT_NUM)
        {
            bPossibleLoadNext = true;
            nOffset++;
        }
        
        [self.m_tableView reloadData];
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
