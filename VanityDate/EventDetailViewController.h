//
//  EventDetailViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface EventDetailViewController : UIViewController<MKMapViewDelegate>
{
    NSDictionary* dictEventInfo;
}

@property (nonatomic, assign) bool m_bAcitivated;

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollView;
@property (nonatomic, strong) NSString *m_strEventName;
@property (nonatomic, strong) NSString *m_strEventId;
@property (weak, nonatomic) IBOutlet UILabel *m_lblEventTitle;

@property (weak, nonatomic) IBOutlet MKMapView *m_mapView;

@property (weak, nonatomic) IBOutlet UILabel *m_lblEventName;
@property (weak, nonatomic) IBOutlet UILabel *m_lblCategory;

@property (weak, nonatomic) IBOutlet UITextView *m_txtDescription;

@property (weak, nonatomic) IBOutlet UILabel *m_lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *m_lblWebSite;
@property (weak, nonatomic) IBOutlet UIView *m_viewWebSite;
- (IBAction)actionCheckWebSite:(id)sender;
- (IBAction)actionSeeCalendar:(id)sender;

@end
