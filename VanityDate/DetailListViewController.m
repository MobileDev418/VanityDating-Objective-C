//
//  DetailListViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/24/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "DetailListViewController.h"
#import "Global.h"

@interface DetailListViewController ()

@end

@implementation DetailListViewController
@synthesize m_arrData;
@synthesize m_arrResult;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Calendar";//self.m_strEventName;

    m_arrResult = [[NSMutableArray alloc] init];
    m_arrData = [[NSMutableArray alloc] init];
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;

    __weak DetailListViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    self.m_tableView.tableFooterView = [[UIView alloc] init];
}

- (void) viewWillAppear:(BOOL)animated
{
    nOffset = 0;
    bPossibleLoadNext = false;
    
    [self getCalendarRequest];
}

- (void) loadBelowMore
{
    if (!bPossibleLoadNext)
    {
        [self.m_tableView.infiniteScrollingView stopAnimating];
        return;
    }
    
    [self getCalendarRequest];
}

- (void) getCalendarRequest
{
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"event/calendar"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:[NSString stringWithFormat:@"%d", nOffset] forKey:@"offset"];
    [request setPostValue:self.m_strEventId forKey:@"event_id"];
    
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];

}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertRowAtBottom {
    __weak DetailListViewController *weakSelf = self;
    
    int64_t delayInSeconds = 0.2f;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        for (int nIdx = (int)weakSelf.m_arrData.count - 1; nIdx >= 0; nIdx--)
        {
            [weakSelf.m_tableView beginUpdates];
            [weakSelf.m_arrResult addObject:[weakSelf.m_arrData objectAtIndex:nIdx]];
            [weakSelf.m_tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.m_arrResult.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
            [weakSelf.m_tableView endUpdates];
        }
        
        [weakSelf.m_tableView.infiniteScrollingView stopAnimating];
    });
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
    return self.m_arrResult.count;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listcell";
    
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary* dictInfo = [m_arrResult objectAtIndex:indexPath.row];
    
    UILabel* lblMonth = (UILabel *)[cell viewWithTag:10];
    UILabel* lblDay = (UILabel *)[cell viewWithTag:11];
    UILabel* lblEventName = (UILabel *)[cell viewWithTag:12];
    UILabel* lblVenue = (UILabel *)[cell viewWithTag:13];
    UILabel* lblTime = (UILabel *)[cell viewWithTag:14];
//    UILabel* lblRealTime = (UILabel *)[cell viewWithTag:16];
    
    UIView* containerView = (UIView *)[cell viewWithTag:15];
    containerView.layer.cornerRadius = 5.f;
    
    NSString* strStateDate = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictInfo valueForKey:@"event_start"] longLongValue]] withFormat:@"yyyy, MMM dd"];

    NSString* strEndDate = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictInfo valueForKey:@"event_end"] longLongValue]] withFormat:@"yyyy, MMM dd"];

    NSString* strStateDateByTime = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictInfo valueForKey:@"event_start"] longLongValue]] withFormat:@"hh:mm a"];
    
    NSString* strEndDateByTime = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictInfo valueForKey:@"event_end"] longLongValue]] withFormat:@"hh:mm a"];

     NSString* strRealTime = @"TBD";
     if (![[dictInfo valueForKey:@"real_time"] isEqualToString:@"TBD"])
     strRealTime = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictInfo valueForKey:@"real_time"] longLongValue]] withFormat:@"hh:mm a"];
    lblTime.text = [NSString stringWithFormat:@"%@", strRealTime];
    
    NSArray* arraySeperateDate = [strStateDate componentsSeparatedByString:@" "];
    lblMonth.text = [arraySeperateDate objectAtIndex:1];
    lblDay.text = [arraySeperateDate lastObject];
    
    lblEventName.text = [dictInfo valueForKey:@"title"];
    lblVenue.text = [dictInfo valueForKey:@"club"];
//    lblTime.text = [NSString stringWithFormat:@"%@ ~ %@", strStateDateByTime, strEndDateByTime];
    
    lblEventName.frame = CGRectMake(lblEventName.frame.origin.x, lblEventName.frame.origin.y, self.view.frame.size.width - 110, lblEventName.frame.size.height);
    lblVenue.frame = CGRectMake(lblVenue.frame.origin.x, lblVenue.frame.origin.y, self.view.frame.size.width - 110, lblVenue.frame.size.height);
    lblTime.frame = CGRectMake(lblTime.frame.origin.x, lblTime.frame.origin.y, self.view.frame.size.width - 110, lblTime.frame.size.height);

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
        [m_arrData removeAllObjects];

        [self.m_tableView reloadData];
        
        m_arrData  = [dictResponse valueForKey:@"result"];
        if (m_arrData.count < MAX_EVENT_NUM)
        {
            bPossibleLoadNext = false;
        }
        else
        {
            bPossibleLoadNext = true;
            nOffset++;
        }
        
        [self insertRowAtBottom];
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
