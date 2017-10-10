//
//  ProfileViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "SelfieCustomView.h"

#define GET_PROFILE_REQUEST     10
#define UPDATE_AVATAR_REQUEST   11
#define DELETE_PHOTO_REQUEST    12

@interface ProfileViewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, SelfieCustomViewDelegate>
{
    int nRequestMode;
    
    NSMutableArray* arrayPhotoViewsAsGrid;
    NSMutableArray* arrayPhotoViewsAsList;
    
    bool bUpdatedImage;
    UIImage* avatarImage;
    
    bool bViewMode;
    
    int nSelectedPhotoIdx;
}

@property (nonatomic, strong) NSMutableArray* m_arrayPhotos;

@property (weak, nonatomic) IBOutlet UIImageView *m_userImageView;

- (IBAction)actionEditImage:(id)sender;
- (IBAction)actionViewGrid:(id)sender;
- (IBAction)actionLocation:(id)sender;
- (IBAction)actionSelfie:(id)sender;
- (IBAction)actionViewList:(id)sender;

@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollViewGrid;
@property (weak, nonatomic) IBOutlet UIScrollView *m_scrollViewList;
@property (weak, nonatomic) IBOutlet MKMapView *m_mapView;


@end
