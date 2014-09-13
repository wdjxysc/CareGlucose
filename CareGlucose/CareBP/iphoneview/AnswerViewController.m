//
//  AnswerViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-11.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "AnswerViewController.h"
#import "MySingleton.h"
#import "ServerConnect.h"
#import "SVProgressHUD.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface AnswerViewController ()

@end

@implementation AnswerViewController

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
    titleLabel.text = @"健康解答";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    //返回按钮
    UIButton *backBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, 30, 44)];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    backBtn.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [backBtn addTarget:self action:@selector(backBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    //webView
    CGRect frame = CGRectMake(0, 64, 320, 416);
    if(iPhone5)
        frame = CGRectMake(0, 64, 320, 504);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
    [webView setScalesPageToFit:YES];
    webView.delegate = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //从服务器获取问题列表
        NSDictionary *answerdic = [ServerConnect terminalGetAnswer:[[_questionDic valueForKey:@"questionId"] intValue]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([[answerdic valueForKey:@"RESULT_CODE"] intValue] == 0)
            {
                NSDictionary *resultinfo = [answerdic valueForKey:@"RESULT_INFO"][0];
                NSString *urlstr = [[NSString alloc]initWithFormat:@"http://%@/sys/appContent_detailContent?type=%d&id=%d",
                                    [MySingleton sharedSingleton].serverDomain,
                                    1,//互动问答
                                    [[resultinfo valueForKey:@"answerId"] intValue]];
                NSURL *url =[NSURL URLWithString:urlstr];
                NSURLRequest *request =[NSURLRequest requestWithURL:url];
                [webView loadRequest:request];
            }
            else
            {
                NSLog(@"ServerConnect terminalGetContent failed");
            }
        });
    });
    
    [self.view addSubview:webView];
}

-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)passValue:(NSDictionary *)value
{
    _questionDic = value;
}



-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL b = YES;
    return b;
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [SVProgressHUD showWithStatus:@""];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:@"加载失败"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [SVProgressHUD dismiss];
}
@end
