//
//  EventSettingViewController.m
//  VanityDate
//
//  Created by iOSDevStar on 7/11/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import "EventSettingViewController.h"
#import "Global.h"

@interface EventSettingViewController ()

@end

@implementation EventSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Search Setting";
    
    FAKFontAwesome *naviBackIcon = [FAKFontAwesome chevronLeftIconWithSize:NAVI_ICON_SIZE];
    [naviBackIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imgButton = [naviBackIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imgButton style:UIBarButtonItemStylePlain target:self action:@selector(backToMainView)];

    FAKFontAwesome *naviRightIcon = [FAKFontAwesome checkIconWithSize:NAVI_ICON_SIZE];
    [naviRightIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *imageRightButton = [naviRightIcon imageWithSize:CGSizeMake(NAVI_ICON_SIZE, NAVI_ICON_SIZE)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:imageRightButton style:UIBarButtonItemStylePlain target:self action:@selector(saveSetting)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveSetting)];

    self.m_viewChoose.hidden = YES;
    
    arrAround = [NSMutableArray arrayWithObjects:@"1 mile", @"3 miles", @"5 miles", @"10 miles", @"25 miles", @"50 miles", @"100 miles", @"500 miles", @"1000 miles", @"2500 miles", @"5000 miles", nil];
    
    nSelectedCategoryIdx = 0;//[[Utils sharedObject] readEventSetting:@"category"];
    nSelectedSubCategoryIdx = 0;//[[Utils sharedObject] readEventSetting:@"subcategory"];
    nSelectedDistanceIdx = 1;//[[Utils sharedObject] readEventSetting:@"around"];

    strSelectedCategory = @"All";
    strSelectedSubCategory = @"All";
    strSelectedDistance = [arrAround objectAtIndex:nSelectedDistanceIdx];
    
    self.m_lblCategory.text = strSelectedCategory;
    self.m_lblSubCategory.text = strSelectedSubCategory;
    self.m_lblDistance.text = strSelectedDistance;
    
    arrCategories = [[NSMutableArray alloc] init];
    arrSubCategories = [[NSMutableArray alloc] init];
    
    self.m_pickerView.delegate = self;
    
    [self getCategories];
}

- (void) backToMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) saveSetting
{
    [self showLoadingView];
    
    nRequestMode = UPDATE_SETTING_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"event/update_search_setting"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setPostValue:[NSString stringWithFormat:@"%d", nSelectedCategoryIdx] forKey:@"category"];
    [request setPostValue:[NSString stringWithFormat:@"%d",nSelectedSubCategoryIdx] forKey:@"sub_category"];
    [request setPostValue:[NSString stringWithFormat:@"%d", nSelectedDistanceIdx] forKey:@"around"];
    
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (void) getCategories
{
    [self showLoadingView];
    
    nRequestMode = CATEGORY_REQUEST;
    
    NSString* strRequestLink = [[Utils sharedObject] makeAPIURLString:@"getCategories"];
    NSURL *url = [NSURL URLWithString:[[Utils sharedObject] urlEncodeWithString:strRequestLink]];
    
    ASIFormDataRequest *request;
    request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    
    [request addRequestHeader:@"Access-Token" value:g_Delegate.m_strAccessToken];
    [request addRequestHeader:@"Device-Id" value:g_Delegate.m_strAccessDeviceId];
    
    [request setRequestMethod:@"POST"];
    [request setPostFormat:ASIURLEncodedPostFormat];
    
    [request startAsynchronous];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    self.m_viewChoose.hidden = YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 32.f;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    if (nSelectedChooseMode == CHOOSE_CATEGORY)
        return [arrCategories count];
    else if (nSelectedChooseMode == CHOOSE_SUB_CATEGORY)
        return [arrSubCategories count];
    else
        return arrAround.count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (nSelectedChooseMode == CHOOSE_CATEGORY)
    {
        NSDictionary* dictCategory = [arrCategories objectAtIndex:row];
        return  [dictCategory valueForKey:@"title"];
    }
    else if (nSelectedChooseMode == CHOOSE_SUB_CATEGORY)
    {
        NSDictionary* dictSubCategory = [arrSubCategories objectAtIndex:row];
        return  [dictSubCategory valueForKey:@"sub_title"];
    }
    else
    {
        return [arrAround objectAtIndex:row];
    }
}

// Picker Delegate
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (nSelectedChooseMode == CHOOSE_CATEGORY)
    {
        NSDictionary* dictCategory = [arrCategories objectAtIndex:row];
        nSelectedCategoryIdx = (int)[[dictCategory valueForKey:@"category_id"] integerValue];
        strSelectedCategory = [dictCategory valueForKey:@"title"];
        self.m_lblCategory.text = [dictCategory valueForKey:@"title"];
        
        [arrSubCategories removeAllObjects];
        if (nSelectedCategoryIdx != 0)
        {
            NSMutableDictionary* dictAll = [[NSMutableDictionary alloc] init];
            [dictAll setValue:nil forKey:@"caption"];
            [dictAll setValue:@"0" forKey:@"sub_category_id"];
            [dictAll setValue:@"All" forKey:@"sub_title"];
            [arrSubCategories addObject:dictAll];
            [arrSubCategories addObjectsFromArray:[dictCategory valueForKey:@"sub_categories"]];
        }
        
        nSelectedSubCategoryIdx = 0;
        strSelectedSubCategory = @"All";
        self.m_lblSubCategory.text = strSelectedSubCategory;

    }
    
    else if (nSelectedChooseMode == CHOOSE_SUB_CATEGORY)
    {
        NSDictionary* dictSubCategory = [arrSubCategories objectAtIndex:row];
        nSelectedSubCategoryIdx = (int)[[dictSubCategory valueForKey:@"sub_category_id"] integerValue];
        strSelectedSubCategory = [dictSubCategory valueForKey:@"sub_title"];
        self.m_lblSubCategory.text = strSelectedSubCategory;
    }
    else if (nSelectedChooseMode == CHOOSE_DISTANCE)
    {
        self.m_lblDistance.text = [arrAround objectAtIndex:row];
    }

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

- (IBAction)actionChooseCategory:(id)sender
{
    if (arrCategories.count == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"There is no one category currently."];
        return;
    }
    
    self.m_lblChooseTitle.title = @"Please choose category";

    nSelectedChooseMode = CHOOSE_CATEGORY;
    [self.m_pickerView reloadAllComponents];
    self.m_viewChoose.hidden = NO;
    
}

- (IBAction)actionChooseSubCategory:(id)sender
{
    if (arrSubCategories.count == 0)
    {
        [g_Delegate AlertWithCancel_btn:@"Please choose category!"];
        return;
    }
 
    self.m_lblChooseTitle.title = @"Please choose subcategory";

    nSelectedChooseMode = CHOOSE_SUB_CATEGORY;
    [self.m_pickerView reloadAllComponents];
    self.m_viewChoose.hidden = NO;
}

- (IBAction)actionChooseDistance:(id)sender
{
    self.m_viewChoose.hidden = NO;
    self.m_lblChooseTitle.title = @"Please choose distance";
    
    nSelectedChooseMode = CHOOSE_DISTANCE;
    [self.m_pickerView reloadAllComponents];
}

- (IBAction)actionChooseDone:(id)sender
{
    self.m_viewChoose.hidden = YES;
    
    int nSelRow = (int)[self.m_pickerView selectedRowInComponent:0];
    if (nSelectedChooseMode == CHOOSE_CATEGORY)
    {
        NSDictionary* dictCategory = [arrCategories objectAtIndex:nSelRow];
        nSelectedCategoryIdx = (int)[[dictCategory valueForKey:@"category_id"] integerValue];
        strSelectedCategory = [dictCategory valueForKey:@"title"];
        self.m_lblCategory.text = strSelectedCategory;
        
        [arrSubCategories removeAllObjects];
        if (nSelectedCategoryIdx != 0)
        {
            NSMutableDictionary* dictAll = [[NSMutableDictionary alloc] init];
            [dictAll setValue:nil forKey:@"caption"];
            [dictAll setValue:@"0" forKey:@"sub_category_id"];
            [dictAll setValue:@"All" forKey:@"sub_title"];
            [arrSubCategories addObject:dictAll];
            [arrSubCategories addObjectsFromArray:[dictCategory valueForKey:@"sub_categories"]];
        }
        else
        {
            nSelectedSubCategoryIdx = 0;
            strSelectedSubCategory = @"All";
            self.m_lblSubCategory.text = strSelectedSubCategory;
        }
    }
    else if (nSelectedChooseMode == CHOOSE_SUB_CATEGORY)
    {
        NSDictionary* dictSubCategory = [arrSubCategories objectAtIndex:nSelRow];
        nSelectedSubCategoryIdx = (int)[[dictSubCategory valueForKey:@"sub_category_id"] integerValue];
        strSelectedSubCategory = [dictSubCategory valueForKey:@"sub_title"];
        self.m_lblSubCategory.text = strSelectedSubCategory;
    }
    else if (nSelectedChooseMode == CHOOSE_DISTANCE)
    {
        nSelectedDistanceIdx = nSelRow;
        strSelectedDistance = [arrAround objectAtIndex:nSelRow];
        
        self.m_lblDistance.text = strSelectedDistance;
    }
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
        if (nRequestMode == UPDATE_SETTING_REQUEST)
        {
            [g_Delegate AlertSuccess:@"Updated search setting successfully!"];
            return;
        }
        
        [arrCategories removeAllObjects];
        if (nRequestMode == CATEGORY_REQUEST)
        {
            NSMutableDictionary* dictAll = [[NSMutableDictionary alloc] init];
            [dictAll setValue:[[NSArray alloc] init] forKey:@"sub_categories"];
            [dictAll setValue:@"0" forKey:@"category_id"];
            [dictAll setValue:@"All" forKey:@"title"];
            
            [arrCategories addObject:dictAll];
            [arrCategories addObjectsFromArray:[dictResponse valueForKey:@"categories"]];
            
            NSDictionary* dictCurrentSettingInfo = [[dictResponse valueForKey:@"user_setting"] lastObject];
            nSelectedCategoryIdx = (int)[[dictCurrentSettingInfo valueForKey:@"category_id"] integerValue];
            nSelectedSubCategoryIdx = (int)[[dictCurrentSettingInfo valueForKey:@"sub_category_id"] integerValue];
            nSelectedDistanceIdx = (int)[[dictCurrentSettingInfo valueForKey:@"around"] integerValue];
            
            strSelectedCategory = @"All";
            strSelectedSubCategory = @"All";
            strSelectedDistance = [arrAround objectAtIndex:nSelectedDistanceIdx];
            
            if (nSelectedCategoryIdx != 0)
            {
                int nRealSelectedCategoryIdx = -1;
                for (int nCateIdx = 0; nCateIdx < arrCategories.count; nCateIdx++)
                {
                    if ([[[arrCategories objectAtIndex:nCateIdx]  valueForKey:@"category_id"] integerValue] == nSelectedCategoryIdx)
                    {
                        strSelectedCategory = [[arrCategories objectAtIndex:nCateIdx]  valueForKey:@"title"];
                        
                        nRealSelectedCategoryIdx = nCateIdx;
                        
                        break;
                    }
                }
                
                if (nRealSelectedCategoryIdx <= 0)
                {
                    self.m_lblCategory.text = strSelectedCategory;
                    self.m_lblSubCategory.text = strSelectedSubCategory;
                    self.m_lblDistance.text = strSelectedDistance;

                    return;
                }
                
                NSDictionary* dictCategory = [arrCategories objectAtIndex:nRealSelectedCategoryIdx];
                
                [arrSubCategories removeAllObjects];
                NSMutableDictionary* dictAll = [[NSMutableDictionary alloc] init];
                [dictAll setValue:nil forKey:@"caption"];
                [dictAll setValue:@"0" forKey:@"sub_category_id"];
                [dictAll setValue:@"All" forKey:@"sub_title"];
                [arrSubCategories addObject:dictAll];
                [arrSubCategories addObjectsFromArray:[dictCategory valueForKey:@"sub_categories"]];

                for (int nSubCateIdx = 0; nSubCateIdx < arrSubCategories.count; nSubCateIdx++)
                {
                    if ([[[arrSubCategories objectAtIndex:nSubCateIdx]  valueForKey:@"sub_category_id"] integerValue] == nSelectedSubCategoryIdx)
                    {
                        strSelectedSubCategory = [[arrSubCategories objectAtIndex:nSubCateIdx]  valueForKey:@"sub_title"];
                        break;
                    }
                }
            }

            self.m_lblCategory.text = strSelectedCategory;
            self.m_lblSubCategory.text = strSelectedSubCategory;
            self.m_lblDistance.text = strSelectedDistance;
            

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

@end
