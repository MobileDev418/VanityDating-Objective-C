//
//  FavoriteViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/10/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* arrResult;
    
    int nOffset;
    bool bPossibleLoadNext;
    
    bool bSearchMode;
}

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;

@end
