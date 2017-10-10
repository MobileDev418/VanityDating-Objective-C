//
//  EventSettingViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CHOOSE_CATEGORY             10
#define CHOOSE_SUB_CATEGORY         11
#define CHOOSE_DISTANCE             12

#define CATEGORY_REQUEST            20
#define UPDATE_SETTING_REQUEST      21

@interface EventSettingViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSMutableArray* arrAround;
    NSMutableArray* arrCategories;
    NSMutableArray* arrSubCategories;
    
    int nRequestMode;
    int nSelectedChooseMode;
    
    int nSelectedCategoryIdx;
    int nSelectedSubCategoryIdx;
    int nSelectedDistanceIdx;

    NSString* strSelectedCategory;
    NSString* strSelectedSubCategory;
    NSString* strSelectedDistance;

}

@property (weak, nonatomic) IBOutlet UILabel *m_lblCategory;
@property (weak, nonatomic) IBOutlet UILabel *m_lblSubCategory;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDistance;

- (IBAction)actionChooseCategory:(id)sender;
- (IBAction)actionChooseSubCategory:(id)sender;
- (IBAction)actionChooseDistance:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *m_viewChoose;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *m_lblChooseTitle;
- (IBAction)actionChooseDone:(id)sender;

@property (weak, nonatomic) IBOutlet UIPickerView *m_pickerView;




@end
