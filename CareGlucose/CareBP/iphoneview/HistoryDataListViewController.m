//
//  HistoryDataListViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-22.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "HistoryDataListViewController.h"
#import "BloodPressTableViewCell.h"
#import "NSDate+Additions.h"
#import "MySingleton.h"
#import "ServerConnect.h"
#import "Regex.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface HistoryDataListViewController ()

@end

@implementation HistoryDataListViewController

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
    _bloodpressDataArray = [[NSMutableArray alloc]init];
    // Do any additional setup after loading the view from its nib.
    [self initMyView];
    
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
    
    //分割线
    UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 155, 320, 0.5)];
    [lineImageView setImage:[UIImage imageNamed:@"横线"]];
    [self.view addSubview:lineImageView];
    
    //tableView
    CGRect tableViewFrame = CGRectMake(0, 165, 320, Screen_height-165-49);
    _myTableView = [[UITableView alloc] initWithFrame:tableViewFrame];
    [self.view addSubview:_myTableView];
    _myTableView.delegate = self;
    _myTableView.dataSource = self;
    _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        _myTableView.separatorInset = UIEdgeInsetsZero;
    }
    
    //没有数据提示label
    _noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 250, 320, 24)];
    _noDataLabel.textColor = [UIColor lightGrayColor];
    _noDataLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    _noDataLabel.text = @"这段时间没有数据哦~";
    _noDataLabel.hidden = YES;
    _noDataLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_noDataLabel];
    
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
    
    //查询数据
    if([[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"])
    {
        _bloodpressDataArray = [self getArrayBetweenFromArray:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"] begintime:_nowBeginTime endtime:_nowEndTime];
        [_myTableView reloadData];
    }
    
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
    
    //查询数据
    if([[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"])
    {
        _bloodpressDataArray = [self getArrayBetweenFromArray:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"] begintime:_nowBeginTime endtime:_nowEndTime];
        [_myTableView reloadData];
    }
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
    
    //查询数据
    if([[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"])
    {
        _bloodpressDataArray = [self getArrayBetweenFromArray:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"] begintime:_nowBeginTime endtime:_nowEndTime];
        [_myTableView reloadData];
    }
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
    begindatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",
                    _nowBeginTimecomps.year,
                    _nowBeginTimecomps.month-_nowBeginTimecomps.month%3+1,
                    1];
    enddatestr = [[NSString alloc]initWithFormat:@"%ld-%02ld-%02d",
                  _nowBeginTimecomps.year,
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
    
    //查询数据
    if([[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"])
    {
        _bloodpressDataArray = [self getArrayBetweenFromArray:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"] begintime:_nowBeginTime endtime:_nowEndTime];
        [_myTableView reloadData];
    }
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
    if([[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"])
    {
        _bloodpressDataArray = [self getArrayBetweenFromArray:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"] begintime:_nowBeginTime endtime:_nowEndTime];
        [_myTableView reloadData];
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
        _bloodpressDataArray = [self getArrayBetweenFromArray:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"UserGlucoseDataArray"] begintime:_nowBeginTime endtime:_nowEndTime];
        [_myTableView reloadData];
    }
}

//@program tableview delegate

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger i = 0;
    
    i = [_bloodpressDataArray count];
    
    if(i == 0)
    {
        _noDataLabel.hidden = NO;
    }
    else
    {
        _noDataLabel.hidden = YES;
    }
    
    return i;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellTableIdentifier = @"CellTableIdentifier";
    UITableViewCell *returncell = [[UITableViewCell alloc]init];
    BloodPressTableViewCell *cell =(BloodPressTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"BloodPressTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSUInteger row = [indexPath row];
    NSDictionary *rowData = [_bloodpressDataArray objectAtIndex:row];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:[rowData objectForKey:@"date"]];
    NSDateComponents *comps = [self getDateComponentsByDate:destDate];
    cell.dayLabel.text = [[NSString alloc]initWithFormat:@"%d",(int)[comps day]];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat: @"HH:mm"];
    NSString *timestr = [timeFormatter stringFromDate:destDate];
    cell.timeLabel.text = timestr;
    
    
    if([Regex validatePositiveFloat:[[NSString alloc] initWithFormat:@"%@",[rowData objectForKey:@"bloodSugar"]]]||
       [Regex validatePositiveInteger:[[NSString alloc] initWithFormat:@"%@",[rowData objectForKey:@"bloodSugar"]]])
    {
        cell.sysDataLabel.text = [[NSString alloc] initWithFormat:@"%.1f",[[rowData objectForKey:@"bloodSugar"] floatValue]];
        
        if([[rowData objectForKey:@"bloodSugar"] floatValue] >= 6.0)
        {
            cell.yuanImageViw.image = [UIImage imageNamed:@"圆2"];
            cell.tipsLabel.text = @"亲，您的血糖偏高!请注意调节!";
        }
        else if([[rowData objectForKey:@"bloodSugar"] floatValue] <= 2.5)
        {
            cell.yuanImageViw.image = [UIImage imageNamed:@"圆2"];
            cell.tipsLabel.text = @"亲，您的血糖偏低!请注意调节!";
        }
    }
    else //数据错误
    {
        cell.sysDataLabel.text = [[NSString alloc] initWithFormat:@"%@",[rowData objectForKey:@"bloodSugar"]];
    }
    
    returncell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    returncell = cell;
    return returncell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = 75.0f;
    return result;
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

@end
