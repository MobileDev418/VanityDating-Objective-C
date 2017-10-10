//
//  EventViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    int nRequestMode;
    
    NSMutableArray* arraySearch;
    
    NSMutableArray* arrResult;
    NSMutableArray* arrayActiveResult;
    int you_are_in;
    NSMutableArray* arraySections;
    
    int nOffset;
    bool bPossibleLoadNext;
    
    bool bSearchMode;
}

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;
@property (weak, nonatomic) IBOutlet UITextField *m_txtSearch;

@end
