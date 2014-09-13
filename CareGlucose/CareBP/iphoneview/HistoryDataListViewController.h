//
//  HistoryDataListViewController.h
//  CareBP
//
//  Created by 夏 伟 on 14-7-22.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDataListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(retain,nonatomic)UIButton *weekBtn;
@property(retain,nonatomic)UIButton *monthBtn;
@property(retain,nonatomic)UIButton *seasonBtn;
@property(retain,nonatomic)UILabel *timeLabel;

@property(retain,nonatomic)UILabel *noDataLabel;

@property (nonatomic,retain)NSString *nowTimeType;
@property (nonatomic,retain)UITableView *myTableView;
@property (nonatomic,retain)NSMutableArray *bloodpressDataArray;

@property(retain,nonatomic)NSDate *nowBeginTime;
@property(retain,nonatomic)NSDate *nowEndTime;
@end
