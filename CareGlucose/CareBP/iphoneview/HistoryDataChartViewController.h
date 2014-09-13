//
//  HistoryDataChartViewController.h
//  CareBP
//
//  Created by 夏 伟 on 14-7-22.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineChartView.h"

@interface HistoryDataChartViewController : UIViewController
@property(retain,nonatomic)UIButton *weekBtn;
@property(retain,nonatomic)UIButton *monthBtn;
@property(retain,nonatomic)UIButton *seasonBtn;
@property(retain,nonatomic)UILabel *timeLabel;

@property (nonatomic,retain)NSString *nowTimeType;
@property (nonatomic,retain)NSMutableArray *bloodpressDataArray;

@property(retain,nonatomic)NSDate *nowBeginTime;
@property(retain,nonatomic)NSDate *nowEndTime;

@property(nonatomic,retain)LineChartView *myLineChartView;
@property(nonatomic,retain)NSMutableArray *dataarray;

@property(nonatomic,retain)UIButton *sysDataBtn;
@property(nonatomic,retain)UIButton *diaDataBtn;
@property(nonatomic,retain)UIButton *pulseDataBtn;
@end
