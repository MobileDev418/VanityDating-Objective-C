//
//  EventDetailViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Global.h"
#import "DetailListViewController.h"

@interface EventDetailViewController ()

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = self.m_strEventName;
    
    self.m_mapView.delegate = self;
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgBack = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgBack style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];
    
}

- (void) customeNavigationBar
{
    UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(60, 0, self.view.bounds.size.width - 120, 44)];
    
    UILabel *title = [[UILabel alloc] initWithFrame: CGRectMake((myView.bounds.size.width - 160) / 2, 0, 160, 28)];
    title.text = @"You're Here!";
    [title setTextColor:[UIColor whiteColor]];
    title.font = [UIFont fontWithName:MAIN_BOLD_FONT_NAME size:24.0f];
    title.textAlignment = NSTextAlignmentCenter;
    title.shadowColor = [UIColor grayColor];
    title.shadowOffset = CGSizeMake(0.0f, 0.0f);
    [title setBackgroundColor:[UIColor clearColor]];
    [myView addSubview:title];
    
    UILabel *subTitle = [[UILabel alloc] initWithFrame: CGRectMake((myView.bounds.size.width - 100) / 2, 28, 100, 16)];

    subTitle.text = self.m_strEventName;
    
    [subTitle setTextColor:[UIColor whiteColor]];
    subTitle.font = [UIFont fontWithName:MAIN_FONT_NAME size:12.0f];
    subTitle.textAlignment = NSTextAlignmentCenter;
    subTitle.shadowColor = [UIColor grayColor];
    subTitle.shadowOffset = CGSizeMake(0.0f, 0.0f);
    [subTitle setBackgroundColor:[UIColor clearColor]];
    [myView addSubview:subTitle];
    
    self.navigationItem.titleView = myView;

    self.navigationController.navigationBar.barTintColor = ACTIVATE_COLOR;
    self.m_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 588);
    self.m_viewWebSite.hidden = NO;
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = NAVI_COLOR;
}

- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.barTintColor = NAVI_COLOR;
    self.m_scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 588);//503.f
    self.m_viewWebSite.hidden = NO;
    
    [self getEventDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) getEventDetail
{
    [self showLoadingView];
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"event/detail"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:self.m_strEventId forKey:@"event_id"];

    [request setRequestMethod:@"POST"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
    
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

-(MapPinAnnotation *)showClusterPoint:(CLLocationCoordinate2D)coords withPos:(NSString *)place
{
    float  zoomLevel = 0.5;
    MKCoordinateRegion region = MKCoordinateRegionMake (coords, MKCoordinateSpanMake (zoomLevel, zoomLevel));
    [self.m_mapView setRegion: [self.m_mapView regionThatFits: region] animated: YES];
    
    MapPinAnnotation* pinAnnotation =
    [[MapPinAnnotation alloc] initWithCoordinates:coords
                                        placeName:place
                                      description:nil];
    [self.m_mapView addAnnotation:pinAnnotation];
    
    return pinAnnotation;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    
    static NSString* myIdentifier = @"eventdetailpin";
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:myIdentifier];
    
    if (!pinView)
    {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:myIdentifier];
//        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }
    
    pinView.image = [UIImage imageNamed:@"map_pin.png"];
    pinView.annotation = annotation;

    return pinView;
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    
    NSString *receivedData = [request responseString];
    NSDictionary* dictResponse = [receivedData JSONValue];
    if (dictResponse == nil)
    {
        [g_Delegate AlertWithCancel_btn:SOMETHING_WRONG];
        return;
    }
    
    if ([[dictResponse valueForKey:@"success"] integerValue] == 1)
    {
        dictEventInfo = [dictResponse valueForKey:@"result"];
        
        self.m_lblEventName.text = [dictEventInfo valueForKey:@"club"];
        self.m_lblCategory.text = [dictEventInfo valueForKey:@"stadium"];
        self.m_txtDescription.text = [dictEventInfo valueForKey:@"description"];
        self.m_lblAddress.text = [dictEventInfo valueForKey:@"address"];
        self.m_lblEventTitle.text = self.m_strEventName;

        self.m_txtDescription.font = [UIFont fontWithName:MAIN_FONT_NAME size:16.f];
        self.m_txtDescription.textColor = [UIColor whiteColor];
        
        self.m_lblWebSite.text = [dictEventInfo valueForKey:@"site_url"];
//        if (self.m_bAcitivated)
        
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[dictEventInfo valueForKey:@"latitude"] floatValue], [[dictEventInfo valueForKey:@"longitude"] floatValue]);
        
        [self showClusterPoint:coordinate withPos:[dictEventInfo valueForKey:@"title"]];
        
        if ( self.m_bAcitivated && [[dictResponse valueForKey:@"r_u_in"] integerValue] == 1)
        {
            [self customeNavigationBar];
        }
    }
    else
    {
        [g_Delegate AlertWithCancel_btn:[dictResponse valueForKey:@"message"]];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self hideLoadingView];
    
    [g_Delegate AlertWithCancel_btn:NET_CONNECTION_ERROR];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionCheckWebSite:(id)sender {
    if (self.m_lblWebSite.text.length == 0)
        return;
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.m_lblWebSite.text]];
}

- (IBAction)actionSeeCalendar:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    DetailListViewController *viewCon = [storyboard instantiateViewControllerWithIdentifier:@"listview"];
    viewCon.m_strEventId = [dictEventInfo valueForKey:@"id"];
    
    [self.navigationController pushViewController:viewCon animated:YES];

}

@end
