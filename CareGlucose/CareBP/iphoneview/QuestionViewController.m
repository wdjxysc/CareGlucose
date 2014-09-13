//
//  ProblemViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-11.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "QuestionViewController.h"
#import "ServerConnect.h"
#import "AnswerListViewController.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface QuestionViewController ()

@end

@implementation QuestionViewController

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
    
    [self getQuestionArray];
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
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, 30, 44)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [backBtn addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:backBtn];
    
    //列表
    CGRect tableFrame = CGRectMake(0, 64, 320, 416);
    if(iPhone5)
    {
        tableFrame = CGRectMake(0, 64, 320, 504);
    }
    _tableView = [[UITableView alloc] initWithFrame:tableFrame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma tableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger i = 0;
    if(_questionArray)
    {
        i = [_questionArray count];
    }
    return i;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //config the cell
    cell.textLabel.text = [[_questionArray objectAtIndex:indexPath.row] valueForKey:@"questionContent"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_questionArray objectAtIndex:indexPath.row];
    AnswerListViewController *answerListViewController = [[AnswerListViewController alloc]initWithNibName:@"AnswerListViewController" bundle:nil];
    [answerListViewController passValue:dic];
    [self.navigationController pushViewController:answerListViewController animated:YES];
}

-(void)getQuestionArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //从服务器获取问题列表
        NSDictionary *dic = [ServerConnect terminalGetQuestion:2];
        if([[dic valueForKey:@"RESULT_CODE"] intValue] == 0)
        {
            _questionArray = [dic valueForKey:@"RESULT_INFO"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dic) {
                [_tableView reloadData];
            }
            else
            {
                NSLog(@"ServerConnect terminalGetContent failed");
            }
        });
    });
}


@end
