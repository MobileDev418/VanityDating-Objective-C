//
//  ChatListViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

#define GET_FRIENDS_REQUEST     10
#define DELETE_CHAT_USER        11

@interface ChatListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MGSwipeTableCellDelegate>
{
    NSMutableArray* arraySearch;
    
    int nRequestMode;
    NSMutableArray* arrResult;
    
    int nOffset;
    bool bPossibleLoadNext;
    
    bool bSearchMode;
    
}

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;

@property (weak, nonatomic) IBOutlet UITextField *m_txtSearch;

@end
