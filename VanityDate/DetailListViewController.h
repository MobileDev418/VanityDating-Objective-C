//
//  DetailListViewController.h
//  VanityDate
//
//  Created by iOSDevStar on 7/24/15.
//  Copyright (c) 2015 iOSDevStar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    int nOffset;
    bool bPossibleLoadNext;
}

@property (nonatomic, strong) NSMutableArray* m_arrData;
@property (nonatomic, strong) NSMutableArray* m_arrResult;

@property (weak, nonatomic) IBOutlet UITableView *m_tableView;
@property (strong, nonatomic) NSString *m_strEventId;

@end
