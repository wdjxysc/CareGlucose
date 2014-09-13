//
//  HistoryDataChartViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-22.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "HistoryDataChartViewController.h"
#import "NSDate+Additions.h"
#import "MySingleton.h"
#import "ServerConnect.h"
#import "LineChartView.h"
#import "Regex.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@interface HistoryDataChartViewController ()

@end

@implementation HistoryDataChartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initMyView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_dataPointTap:) name:dataPointTapNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMyView
{
    //设置状态栏字体颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //本页标题图片
    UIImageView *topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    [topImageView setImage:[UIImage imageNamed:@"navibar_bg"]];
    [self.view addSubview:topImageView];
    
    //本页标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 30, 100, 24)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    titleLabel.text = @"呵护血糖";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    //周月年框
    UIImageView *wmyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 89, 220, 25)];
    wmyImageView.image = [UIImage imageNamed:@"周月季外框"];
    [self.view addSubview:wmyImageView];
    //周月年按钮
    _weekBtn = [[UIButton alloc] initWithFrame:CGRectMake(50.5, 89, 73, 25)];
    _weekBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_weekBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_weekBtn setTitle:NSLocalizedString(@"WEEK", @"周查询") forState:UIControlStateNormal];
    [_weekBtn setBackgroundImage:[UIImage imageNamed:@"周月季选中框"] forState:UIControlStateNormal];
    [_weekBtn addTarget:self action:@selector(weekBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_weekBtn];
    _monthBtn = [[UIButton alloc] initWithFrame:CGRectMake(123.5, 89, 73, 25)];
    _monthBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_monthBtn setTitle:NSLocalizedString(@"MONTH", @"月查询") forState:UIControlStateNormal];
    [_monthBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    [_monthBtn addTarget:self action:@selector(monthBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_monthBtn];
    _seasonBtn = [[UIButton alloc] initWithFrame:CGRectMake(196.5, 89, 73, 25)];
    _seasonBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [_seasonBtn setTitle:NSLocalizedString(@"SEASON", @"季查询") forState:UIControlStateNormal];
    [_seasonBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    [_seasonBtn addTarget:self action:@selector(seasonBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_seasonBtn];
    
    //时间选择框
    UIImageView *timeChooseImageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 122, 220, 25)];
    timeChooseImageView.image = [UIImage imageNamed:@"日期框"];
    [self.view addSubview:timeChooseImageView];
    UIButton *previousBtn = [[UIButton alloc]initWithFrame:CGRectMake(60, 122.5, 24, 24)];
    [previousBtn setBackgroundImage:[UIImage imageNamed:@"向左"] forState:UIControlStateNormal];
    [previousBtn addTarget:self action:@selector(previousBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previousBtn];
    UIButton *nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(236, 122.5, 24, 24)];
    [nextBtn setBackgroundImage:[UIImage imageNamed:@"向右"] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(nextBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextBtn];
    _timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 124, 140, 21)];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"07月01日 - 07月31日";
    _timeLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:_timeLabel];
    
    //下方显示3个具体数据
    _sysDataBtn = [[UIButton alloc] initWithFrame:CGRectMake(27, Screen_height-128, 53, 53)];
    [_sysDataBtn setBackgroundImage:[UIImage imageNamed:@"圆"] forState:UIControlStateNormal];
    [_sysDataBtn setTitle:@"0" forState:UIControlStateNormal];
    [_sysDataBtn setTitleColor:UIColorFromRGB(0x00668e) forState:UIControlStateNormal];
//    [self.view addSubview:_sysDataBtn];
    UILabel *sysDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(27, Screen_height-75, 53, 20)];
    sysDataLabel.text = NSLocalizedString(@"USER_SYS", @"收缩压");
    sysDataLabel.textColor = UIColorFromRGB(0x999999);
    sysDataLabel.font = [UIFont systemFontOfSize:13];
    sysDataLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:sysDataLabel];
    _diaDataBtn = [[UIButton alloc] initWithFrame:CGRectMake(27+53+53.5, Screen_height-128, 53, 53)];
    [_diaDataBtn setBackgroundImage:[UIImage imageNamed:@"圆"] forState:UIControlStateNormal];
    [_diaDataBtn setTitle:@"0" forState:UIControlStateNormal];
    [_diaDataBtn setTitleColor:UIColorFromRGB(0x00668e) forState:UIControlStateNormal];
    [self.view addSubview:_diaDataBtn];
    UILabel *diaDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(27+53+53.5, Screen_height-75, 53, 20)];
    diaDataLabel.text = NSLocalizedString(@"USER_GLUCOSE", @"血糖");
    diaDataLabel.textColor = UIColorFromRGB(0x999999);
    diaDataLabel.font = [UIFont systemFontOfSize:13];
    diaDataLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:diaDataLabel];
    _pulseDataBtn = [[UIButton alloc] initWithFrame:CGRectMake(27+53*2+53.5*2, Screen_height-128, 53, 53)];
    [_pulseDataBtn setBackgroundImage:[UIImage imageNamed:@"圆"] forState:UIControlStateNormal];
    [_pulseDataBtn setTitle:@"0" forState:UIControlStateNormal];
    [_pulseDataBtn setTitleColor:UIColorFromRGB(0x00668e) forState:UIControlStateNormal];
//    [self.view addSubview:_pulseDataBtn];
    UILabel *pulseDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(27+53*2+53.5*2, Screen_height-75, 53, 20)];
    pulseDataLabel.text = NSLocalizedString(@"USER_PULSE", @"脉搏");
    pulseDataLabel.textColor = UIColorFromRGB(0x999999);
    pulseDataLabel.font = [UIFont systemFontOfSize:13];
    pulseDataLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:pulseDataLabel];
    
    
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *datestr = [formatter stringFromDate:date];
    NSDateComponents *comps = [self getDateComponentsByDate:date];
    _nowBeginTime = [[formatter dateFromString:datestr]dateByAddingDays:-([comps weekday]-1)];
    _nowEndTime = [_nowBeginTime dateByAddingDays:7];
    NSDateComponents *_nowBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
    NSDateComponents *_nowEndTimecomps = [self getDateComponentsByDate:[_nowEndTime dateByAddingDays:-1]];
    _nowTimeType = @"week";
    _timeLabel.text = [[NSString alloc] initWithFormat:@"%02d月%02d日 - %02d月%02d日",
                       (int)_nowBeginTimecomps.month,
                       (int)_nowBeginTimecomps.day,
                       (int)_nowEndTimecomps.month,
                       (int)_nowEndTimecomps.day];
    //显示曲线
    [self showGlucoseChart:_nowBeginTime endtime:_nowEndTime];
}

-(void)weekBtnPressed
{
    [_weekBtn setBackgroundImage:[UIImage imageNamed:@"周月季选中框"] forState:UIControlStateNormal];
    [_weekBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_monthBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_monthBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    [_seasonBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_seasonBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *datestr = [formatter stringFromDate:date];
    NSDateComponents *comps = [self getDateComponentsByDate:date];
    _nowBeginTime = [[formatter dateFromString:datestr]dateByAddingDays:-([comps weekday]-1)];
    _nowEndTime = [_nowBeginTime dateByAddingDays:7];
    
    _nowTimeType = @"week";
    NSDateComponents *_newBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
    NSDateComponents *_newEndTimecomps = [self getDateComponentsByDate:[_nowEndTime dateByAddingDays:-1]];
    _timeLabel.text = [[NSString alloc] initWithFormat:@"%02d月%02d日 - %02d月%02d日",
                       (int)_newBeginTimecomps.month,
                       (int)_newBeginTimecomps.day,
                       (int)_newEndTimecomps.month,
                       (int)_newEndTimecomps.day];
    
    //显示曲线
    [self showGlucoseChart:_nowBeginTime endtime:_nowEndTime];
}

-(void)monthBtnPressed
{
    [_monthBtn setBackgroundImage:[UIImage imageNamed:@"周月季选中框"] forState:UIControlStateNormal];
    [_monthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_weekBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_weekBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    [_seasonBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_seasonBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    
    NSDateComponents *_nowBeginTimecomps = [self getDateComponentsByDate:[NSDate date]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *begindatestr;
    NSString *enddatestr;
    begindatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",
                    (long)_nowBeginTimecomps.year,
                    (long)_nowBeginTimecomps.month,
                    1];
    enddatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",
                  (long)_nowBeginTimecomps.year,
                  _nowBeginTimecomps.month+1,
                  1];
    _nowBeginTime = [formatter dateFromString:begindatestr];
    _nowEndTime = [formatter dateFromString:enddatestr];
    
    _nowTimeType = @"month";
    NSDateComponents *_newBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
    NSDateComponents *_newEndTimecomps = [self getDateComponentsByDate:[_nowEndTime dateByAddingDays:-1]];
    _timeLabel.text = [[NSString alloc] initWithFormat:@"%02d月%02d日 - %02d月%02d日",
                       (int)_newBeginTimecomps.month,
                       (int)_newBeginTimecomps.day,
                       (int)_newEndTimecomps.month,
                       (int)_newEndTimecomps.day];
    
    //显示曲线
    [self showGlucoseChart:_nowBeginTime endtime:_nowEndTime];
}

-(void)seasonBtnPressed
{
    [_seasonBtn setBackgroundImage:[UIImage imageNamed:@"周月季选中框"] forState:UIControlStateNormal];
    [_seasonBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_monthBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_monthBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    [_weekBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [_weekBtn setTitleColor:[UIColor colorWithRed:71/255.0f green:180/255.0f blue:223/255.0f alpha:1.0] forState:UIControlStateNormal];
    
    NSDateComponents *_nowBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *begindatestr;
    NSString *enddatestr;
    begindatestr = [[NSString alloc]initWithFormat:@"%ld-%02d-%02d",
                    (long)_nowBeginTimecomps.year,
                    _nowBeginTimecomps.month-_nowBeginTimecomps.month%3+1,
                    1];
    enddatestr = [[NSString alloc]initWithFormat:@"%ld-%02d-%02d",
                  (long)_nowBeginTimecomps.year,
                  _nowBeginTimecomps.month-_nowBeginTimecomps.month%3+4,
                  1];
    _nowBeginTime = [formatter dateFromString:begindatestr];
    _nowEndTime = [formatter dateFromString:enddatestr];
    _nowTimeType = @"season";
    
    NSDateComponents *_newBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
    NSDateComponents *_newEndTimecomps = [self getDateComponentsByDate:[_nowEndTime dateByAddingDays:-1]];
    _timeLabel.text = [[NSString alloc] initWithFormat:@"%02d月%02d日 - %02d月%02d日",
                       (int)_newBeginTimecomps.month,
                       (int)_newBeginTimecomps.day,
                       (int)_newEndTimecomps.month,
                       (int)_newEndTimecomps.day];
    
    //显示曲线
    [self showGlucoseChart:_nowBeginTime endtime:_nowEndTime];
}

-(void)previousBtnPressed
{
    if([_nowTimeType isEqualToString:@"week"])
    {
        _nowEndTime = _nowBeginTime;
        _nowBeginTime = [_nowBeginTime dateByAddingDays:-7];
    }
    else if([_nowTimeType isEqualToString:@"month"])
    {
        NSDateComponents *_nowBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *begindatestr;
        if (_nowBeginTimecomps.month == 1) {
            begindatestr = [[NSString alloc]initWithFormat:@"%ld-%02d-%02d",_nowBeginTimecomps.year-1,12,1];
        }
        else
        {
            begindatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",(long)_nowBeginTimecomps.year,_nowBeginTimecomps.month-1,1];
        }
        _nowEndTime = _nowBeginTime;
        _nowBeginTime = [formatter dateFromString:begindatestr];
    }
    else if([_nowTimeType isEqualToString:@"season"])
    {
        NSDateComponents *_nowBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *begindatestr;
        if (_nowBeginTimecomps.month <= 3) {
            begindatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",
                            _nowBeginTimecomps.year-1,
                            12+_nowBeginTimecomps.month-3,
                            1];
        }
        else
        {
            begindatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",(long)_nowBeginTimecomps.year,_nowBeginTimecomps.month-3,1];
        }
        _nowEndTime = _nowBeginTime;
        _nowBeginTime = [formatter dateFromString:begindatestr];
    }
    //更新界面显示时间
    NSDateComponents *_newBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
    NSDateComponents *_newEndTimecomps = [self getDateComponentsByDate:[_nowEndTime dateByAddingDays:-1]];
    _timeLabel.text = [[NSString alloc] initWithFormat:@"%02d月%02d日 - %02d月%02d日",
                       (int)_newBeginTimecomps.month,
                       (int)_newBeginTimecomps.day,
                       (int)_newEndTimecomps.month,
                       (int)_newEndTimecomps.day];
    
    //查询数据
    //查询数据
    if([[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"])
    {
        [self showGlucoseChart:_nowBeginTime endtime:_nowEndTime];
    }
}

-(void)nextBtnPressed
{
    if([_nowTimeType isEqualToString:@"week"])
    {
        _nowBeginTime = _nowEndTime;
        _nowEndTime = [_nowEndTime dateByAddingDays:7];
    }
    else if([_nowTimeType isEqualToString:@"month"])
    {
        NSDateComponents *_nowEndTimecomps = [self getDateComponentsByDate:_nowEndTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *enddatestr;
        if (_nowEndTimecomps.month == 12) {
            enddatestr = [[NSString alloc]initWithFormat:@"%ld-%02d-%02d",_nowEndTimecomps.year+1,1,1];
        }
        else
        {
            enddatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",(long)_nowEndTimecomps.year,_nowEndTimecomps.month+1,1];
        }
        _nowBeginTime = _nowEndTime;
        _nowEndTime = [formatter dateFromString:enddatestr];
    }
    else if([_nowTimeType isEqualToString:@"season"])
    {
        NSDateComponents *_nowEndTimecomps = [self getDateComponentsByDate:_nowEndTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *enddatestr;
        if (_nowEndTimecomps.month >= 10) {
            enddatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",
                          _nowEndTimecomps.year+1,
                          _nowEndTimecomps.month+3-12,
                          1];
        }
        else
        {
            enddatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",(long)_nowEndTimecomps.year,_nowEndTimecomps.month+3,1];
        }
        _nowBeginTime = _nowEndTime;
        _nowEndTime = [formatter dateFromString:enddatestr];
    }
    //更新界面显示时间
    NSDateComponents *_newBeginTimecomps = [self getDateComponentsByDate:_nowBeginTime];
    NSDateComponents *_newEndTimecomps = [self getDateComponentsByDate:[_nowEndTime dateByAddingDays:-1]];
    _timeLabel.text = [[NSString alloc] initWithFormat:@"%02d月%02d日 - %02d月%02d日",
                       (int)_newBeginTimecomps.month,
                       (int)_newBeginTimecomps.day,
                       (int)_newEndTimecomps.month,
                       (int)_newEndTimecomps.day];
    
    //查询数据
    if([[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"])
    {
        [self showGlucoseChart:_nowBeginTime endtime:_nowEndTime];
    }
}



-(NSDateComponents *)getDateComponentsByDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit |
    NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:date];
    return comps;
}

//从一个序列化数据数组中获取一段时间内的数据
-(NSMutableArray *)getArrayBetweenFromArray : (NSArray *)array begintime:(NSDate *)begintime endtime : (NSDate *)endtime
{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    
    if(array == nil || array.count == 0)
    {
        return result;
    }
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        for(int i = 0; i<array.count; i++)
        {
            NSDate *date = [formatter dateFromString:[array[i] valueForKey:@"date"]];
            if([date compare:begintime] != NSOrderedAscending && [date compare:endtime] != NSOrderedDescending)
            {
                [result addObject:array[i]];
            }
        }
    }
    
    return result;
}

//血糖图表
-(void)showGlucoseChart:(NSDate *)begintime endtime:(NSDate *)endtime
{
    if(_myLineChartView != nil)[_myLineChartView removeFromSuperview];
    
    CGRect myChartFrame = CGRectMake(0,  157, 320, 190);
    
    if(iPhone5)
    {
        myChartFrame = CGRectMake(0, 157, 320, 270);
    }
    
    self.nowBeginTime = begintime;
    self.nowEndTime = endtime;
    
//    LineChartData *sysline = [self getBloodPressLine:@"systolic" title:NSLocalizedString(@"USER_SYS", nil) linecolor:UIColorFromRGB(0xf7a649) begintime:begintime endtime:endtime];
    LineChartData *glucoseline = [self getGlucoseLine:@"bloodSugar" title:NSLocalizedString(@"USER_GLUCOSE", nil) linecolor:UIColorFromRGB(0x78bb66) begintime:begintime endtime:endtime];
//    LineChartData *pulseline = [self getBloodPressLine:@"pulse" title:NSLocalizedString(@"USER_PULSE", nil) linecolor:UIColorFromRGB(0xf96a3a) begintime:begintime endtime:endtime];
    
    _myLineChartView = [[LineChartView alloc] initWithFrame:myChartFrame];
    _myLineChartView.yMin = 0;
    _myLineChartView.yMax = 10;
    _myLineChartView.ySteps = @[@"0",@"2",@"4",@"6",@"8",@"10"];
    _myLineChartView.data = @[glucoseline];
    _myLineChartView.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0];
    
    [self.view addSubview:_myLineChartView];
}


-(LineChartData *)getGlucoseLine:(NSString *)dataname title:(NSString *)title linecolor:(UIColor *)linecolor begintime:(NSDate *)begintime endtime:(NSDate *)endtime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    LineChartData *data = [LineChartData new];
    {
        LineChartData *d1 = data;
        
        _dataarray = [self getArrayBetweenFromArray:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"] begintime:begintime endtime:endtime];
        
        
        d1.xMin = [begintime timeIntervalSinceReferenceDate];
        d1.xMax = [endtime timeIntervalSinceReferenceDate];
        d1.title = title;
        d1.color = linecolor;
        d1.itemCount = [_dataarray count];
        NSMutableArray *arr = [NSMutableArray array];
        
        for(NSUInteger i = 0; i < d1.itemCount; ++i) {
            NSDate *testtime = [formatter dateFromString:[_dataarray[i] valueForKey:@"date"]];
            long item = [testtime timeIntervalSinceReferenceDate];
            [arr addObject:@(item)];
            //            [arr addObject:@(d1.xMin + (rand() / (float)RAND_MAX) * (d1.xMax - d1.xMin))];
        }
        //        [arr addObject:@(d1.xMin)];
        //        [arr addObject:@(d1.xMax)];
        //        [arr sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        //            return [obj1 compare:obj2];
        //        }];
        
        NSMutableArray *arr2 = [NSMutableArray array];
        for(NSUInteger i = 0; i < d1.itemCount; ++i) {
            float y = 0;
            if([Regex validatePositiveFloat:[[NSString alloc] initWithFormat:@"%@",[_dataarray[i] valueForKey:dataname]]]||[Regex validatePositiveInteger:[[NSString alloc] initWithFormat:@"%@",[_dataarray[i] valueForKey:dataname]]]){
                y = [[_dataarray[i] valueForKey:dataname] floatValue];
                
            }
            [arr2 addObject:@(y)];
            //            [arr2 addObject:@((rand() / (float)RAND_MAX) * 6)];
        }
        d1.getData = ^(NSUInteger item) {
            float x = [arr[item] floatValue];
            float y = [arr2[item] floatValue];
            
            NSString *label1 = [formatter stringFromDate:[formatter dateFromString:[_dataarray[item] valueForKey:@"date"]]];
            NSString *label2 = [NSString stringWithFormat:@"%.1f", y];
            return [LineChartDataItem dataItemWithX:x y:y xLabel:label1 dataLabel:label2];
        };
    }
    
    return data;
}

-(void)_dataPointTap:(NSNotification *)notification
{
    NSLog(@"%@",(NSString *)[notification object]);
    NSString *datestr = (NSString *)[notification object];
    for (int i = 0; i < [_dataarray count]; i++) {
        if([[_dataarray[i] valueForKey:@"date"] isEqualToString:datestr])
        {
            if([Regex validatePositiveFloat:[[NSString alloc] initWithFormat:@"%@",[_dataarray[i] valueForKey:@"bloodSugar"]]]||[Regex validatePositiveInteger:[[NSString alloc] initWithFormat:@"%@",[_dataarray[i] valueForKey:@"bloodSugar"]]]){
            [_diaDataBtn setTitle:[[NSString alloc]initWithFormat:@"%.1f",[[_dataarray[i] valueForKey:@"bloodSugar"] floatValue]] forState:UIControlStateNormal];
            }
            else
            {
                [_diaDataBtn setTitle:@"0" forState:UIControlStateNormal];
            }
        }
    }
}

@end
