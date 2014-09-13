//
//  HistoryViewController.h
//  CareBP
//
//  Created by 夏 伟 on 14-7-16.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

@property(retain,nonatomic)UITableView *tableView;

@end
