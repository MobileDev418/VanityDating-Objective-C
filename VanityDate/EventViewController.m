//
//  EventViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "EventViewController.h"
#import "Global.h"
#import "EventSettingViewController.h"
#import "EventDetailViewController.h"
#import "AdsViewController.h"
#import "HomeViewController.h"

@interface EventViewController ()

@end

#define GET_EVENTS_LIST             320
#define LOAD_ADS_REQUEST            321

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Events";

    nOffset = 0;

    arrResult = [[NSMutableArray alloc] init];
    arraySearch = [[NSMutableArray alloc] init];
    arrayActiveResult = [[NSMutableArray alloc] init];
    arraySections = [[NSMutableArray alloc] init];

    self.m_txtSearch.delegate = self;
    self.m_txtSearch.returnKeyType = UIReturnKeySearch;
    
    [self modifyClearButtonWithImage];

    [self.m_txtSearch addTarget:self action:@selector(doSearch) forControlEvents:UIControlEventEditingChanged];
    
    self.m_tableView.delegate = self;
    self.m_tableView.dataSource = self;

    FAKFontAwesome *naviRightIcon = [FAKFontAwesome cogIconWithSize:NAVI_ICON_SIZE];
    [naviRightIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imageRightButton = [naviRightIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imageRightButton style:UIBarButtonItemStylePlain target:self action:@selector(eventSetting)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(eventSetting)];
    nOffset = 0;
    bPossibleLoadNext = true;
    
    __weak EventViewController *weakSelf = self;
    
    // setup pull-to-refresh
    [self.m_tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadBelowMore];
    }];

    self.m_tableView.tableFooterView = [[UIView alloc] init];
    
    self.m_txtSearch.text = @"";
    
    bSearchMode = false;
    you_are_in = 0;
    //show ads
    [self getEvent];
    
    [self performSelector:@selector(loadAdsRequest) withObject:nil afterDelay:0.1f];
}

- (void) loadBelowMore
{
    if (bSearchMode)
        return;
    
    if (bPossibleLoadNext)
        [self getEvent];
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
}

- (void) loadAdsRequest
{
    if (!g_Delegate.bLoadAds)
    {
        g_Delegate.bLoadAds = true;
        
        AdsViewController* viewCon = [self.storyboard instantiateViewControllerWithIdentifier:@"adsview"];
        
        [g_Delegate.m_curHomeViewCon addChildViewController:viewCon];
        [g_Delegate.m_curHomeViewCon.view addSubview:viewCon.view];
        [viewCon didMoveToParentViewController:g_Delegate.m_curHomeViewCon];
    }
}

- (void) getEvent
{
    if (g_Delegate.bLoadAds)
        [self showLoadingView];
    
    nRequestMode = GET_EVENTS_LIST;

    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"event/getEvent"];
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

- (void) eventSetting
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    EventSettingViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"eventsettingview"];
    
    [self.navigationController pushViewController:viewCon animated:YES];
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

- (void) doSearch
{
    [arraySearch removeAllObjects];
    
    if (self.m_txtSearch.text.length == 0)
    {
        arraySearch = [arrResult mutableCopy];
        
        bSearchMode = false;
    }
    else
    {
        bSearchMode = true;
        
        for (int nIdx = 0; nIdx < arrResult.count; nIdx++)
        {
            NSDictionary* dictInfo = [arrResult objectAtIndex:nIdx];
            if ([[[dictInfo valueForKey:@"title"] lowercaseString] rangeOfString:[self.m_txtSearch.text lowercaseString]].location != NSNotFound)
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.m_txtSearch resignFirstResponder];
}

-(void) tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view isKindOfClass: [UITableViewHeaderFooterView class]]) {
        UITableViewHeaderFooterView* castView = (UITableViewHeaderFooterView*) view;
        UIView* content = castView.contentView;
        if (arraySections.count == 2)
        {
            if (section == 0)
                content.backgroundColor = ACTIVATE_COLOR;
            else
                content.backgroundColor = OTHER_EVENT_COLOR;
        }
        else
            content.backgroundColor = OTHER_EVENT_COLOR;
        
        NSString* strTitle = [arraySections objectAtIndex:section];
        [castView.textLabel setTextColor:[UIColor whiteColor]];
        castView.textLabel.textAlignment = NSTextAlignmentCenter;
        castView.textLabel.font = [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:14.f];//[UIFont boldSystemFontOfSize:12.0];
        
        castView.textLabel.text = strTitle;
        
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return arraySections.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arraySections.count == 2)
    {
        if (section == 0)
            return arrayActiveResult.count;
        else
            return arraySearch.count;
    }
    else
        return arraySearch.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"eventcell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary* dictInfo = nil;

    if (arraySections.count == 2)
    {
        if (indexPath.section == 0)
            dictInfo = [arrayActiveResult objectAtIndex:indexPath.row];
        else
            dictInfo = [arraySearch objectAtIndex:indexPath.row];
    }
    else
        dictInfo = [arraySearch objectAtIndex:indexPath.row];
    
    UIImageView* imageView = (UIImageView *)[cell viewWithTag:10];
    UILabel* lblName = (UILabel *)[cell viewWithTag:11];
    UILabel* lblContent = (UILabel *)[cell viewWithTag:12];
    
    imageView.image = [UIImage imageNamed:DEFAULT_EVENT_IMAGE];
    imageView.layer.cornerRadius = imageView.frame.size.height / 2;
    imageView.layer.borderWidth = 4.f;
    imageView.layer.borderColor = CORNER_BORDER_COLOR.CGColor;
    imageView.clipsToBounds = YES;
    
    NSString* strRealTime = @"TBD";
    if (![[dictInfo valueForKey:@"real_time"] isEqualToString:@"TBD"])
        strRealTime = [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictInfo valueForKey:@"real_time"] longLongValue]] withFormat:@"hh:mm a"];

    lblName.text = [dictInfo valueForKey:@"title"];
    lblContent.text = [dictInfo valueForKey:@"description"];
    
    lblContent.text = [NSString stringWithFormat:@"%@ - %@", [[Utils sharedObject] DateToString:[[Utils sharedObject] getDateFromMilliSec:[[dictInfo valueForKey:@"event_start"] longLongValue]] withFormat:@"yyyy, MMM dd"], strRealTime];

    [[Utils sharedObject] loadImageFromServerAndLocalWithoutRound:[NSString stringWithFormat:@"%@%@", CATEGORY_IMAGEA_URL, [dictInfo valueForKey:@"caption"]] imageView:imageView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dictInfo = nil;
    
    bool bActivatedEvent = false;
    if (arraySections.count == 2)
    {
        if (indexPath.section == 0)
        {
            dictInfo = [arrayActiveResult objectAtIndex:indexPath.row];
            bActivatedEvent = true;
        }
        else
            dictInfo = [arraySearch objectAtIndex:indexPath.row];
    }
    else
        dictInfo = [arraySearch objectAtIndex:indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    EventDetailViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"eventdetailview"];
    viewCon.m_strEventId = [dictInfo valueForKey:@"id"];
    viewCon.m_strEventName = [dictInfo valueForKey:@"title"];
    viewCon.m_bAcitivated = bActivatedEvent;
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
        if (nRequestMode == GET_EVENTS_LIST)
        {
            [arrResult removeAllObjects];
            [arraySections removeAllObjects];
            [arrayActiveResult removeAllObjects];
            
            arrayActiveResult = [[dictResponse valueForKey:@"active_event"] mutableCopy];
            you_are_in = (int)[[dictResponse valueForKey:@"you_are_in"] integerValue];
            if (arrayActiveResult.count > 0)
            {
                if(you_are_in > 0){
                    [arraySections addObject:@"Activated Event"];
                }else{
                    [arraySections addObject:@"Activate Events"];
                }
            }
            
            [arraySections addObject:@"Other Events"];
            arrResult = [dictResponse valueForKey:@"result"];
            
            [arraySearch addObjectsFromArray:[arrResult mutableCopy]];
            
            
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
        }
    }
    else
        [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self.m_tableView.infiniteScrollingView stopAnimating];

    bPossibleLoadNext = true;
    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

@end
