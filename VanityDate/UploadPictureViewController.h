//
//  UploadPictureViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadPictureViewController : UIViewController<UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>
{
    UIImage* uploadImage;
}

@property (weak, nonatomic) IBOutlet UIImageView *m_bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *m_btnActionBack;
@property (weak, nonatomic) IBOutlet UIImageView *m_uploadImageView;
- (IBAction)actionTakePhoto:(id)sender;
- (IBAction)actionBack:(id)sender;

- (IBAction)actionUploadPhoto:(id)sender;
@end
