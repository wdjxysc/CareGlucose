//
//  HistoryViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-16.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "HistoryViewController.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface HistoryViewController ()

@end

@implementation HistoryViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initMyView
{
    
    CGRect tableViewFrame = CGRectMake(0, 200, 320, 280);
    if(iPhone5)
    {
        tableViewFrame = CGRectMake(0, 200, 320, 368);
    }
    _tableView = [[UITableView alloc]initWithFrame:tableViewFrame];
    _tableView.backgroundColor = [UIColor grayColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    UIPanGestureRecognizer *tabelViewPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    tabelViewPan.delegate = self;
    [_tableView addGestureRecognizer:tabelViewPan];
//    [self.view addGestureRecognizer:tabelViewPan];
    
    NSLog(@"%f   %f",_tableView.frame.origin.x,_tableView.center.y);
}

- (void)handlePan:(UIPanGestureRecognizer*) recognizer
{
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointZero inView:self.view];
    recognizer.view.frame = CGRectMake(0, recognizer.view.frame.origin.y, 320, Screen_height-recognizer.view.frame.origin.y);
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        if(recognizer.view.frame.origin.y < 70 )
        {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                recognizer.view.frame = CGRectMake(0, 64, 320, Screen_height-64);
            } completion:nil];
        }
        else if(recognizer.view.frame.origin.y >= 70)
        {
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                recognizer.view.frame = CGRectMake(0, 200, 320, Screen_height-200);
            } completion:nil];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger i = 0;
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
    
    
    return cell;
}

-(void)tableViewHandlePan:(UIPanGestureRecognizer *)recognizer
{
    NSLog(@"拖动！");
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL b = YES;
    // 输出点击的view的类名
    NSLog(@"%@", NSStringFromClass([touch.view class]));
    
    
    // 若为UITableViewCellContentView（即点击了tableViewCell），则不截获Touch事件
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        
        NSLog(@"vx:%f    vy:%f", [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:[[gestureRecognizer view] superview]].x,[(UIPanGestureRecognizer *)gestureRecognizer velocityInView:[[gestureRecognizer view] superview]].y);
        if (_tableView.frame.origin.y == 64 && [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:[[gestureRecognizer view] superview]].y < 0) {
            b = NO;
        }
        else if(_tableView.frame.origin.y == 200 && [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:[[gestureRecognizer view] superview]].y > 0)
        {
            b = NO;
        }
    }
    return  b;
}


@end
