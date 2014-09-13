//
//  AnswerListViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-30.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "AnswerListViewController.h"
#import "ServerConnect.h"
#import "AnswerViewController.h"
#import "AnswerTableViewCell.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface AnswerListViewController ()

@end

@implementation AnswerListViewController

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
    
    [self getAnswerArray];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getAnswerArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //从服务器获取答案列表
        NSDictionary *dic = [ServerConnect terminalGetAnswer:[[_questionDic valueForKey:@"questionId"] intValue]];
        if([[dic valueForKey:@"RESULT_CODE"] intValue] == 0)
        {
            _answerArray = [dic valueForKey:@"RESULT_INFO"];
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
    [self.view addSubview:backBtn];
    
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
    if(_answerArray)
    {
        i = [_answerArray count];
    }
    return i;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *returncell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnswerTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    //config the cell
    cell.title.text = [[_answerArray objectAtIndex:indexPath.row] valueForKey:@"answerTitle"];
    cell.content.text = [[_answerArray objectAtIndex:indexPath.row] valueForKey:@"answerSummary"];
//    cell.imageView.image = [UIImage imageNamed:@"圆1"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //从服务器获取问题列表
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[_answerArray objectAtIndex:indexPath.row] valueForKey:@"thumbnailUrl"]]];//适用于加载在网页上的图片
        UIImage *image = [UIImage imageWithData:data];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image) {
//                cell.imageView.image = image;
//                cell.imageView.image = [UIImage imageNamed:@"圆1"];
                cell.image.image = image;
            }
            else {
//                cell.imageView.image = [UIImage imageNamed:@"圆1"];
                NSLog(@"-- impossible download");
            }
        });
        
    });
    returncell = cell;
    return returncell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [_answerArray objectAtIndex:indexPath.row];
    AnswerViewController *answerViewController = [[AnswerViewController alloc]initWithNibName:@"AnswerViewController" bundle:nil];
    [answerViewController passValue:dic];
    [self.navigationController pushViewController:answerViewController animated:YES];
}

-(void)passValue:(NSDictionary *)value
{
    _questionDic = value;
}

@end
