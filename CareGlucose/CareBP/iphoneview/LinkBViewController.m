//
//  LinkBViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-11.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "LinkBViewController.h"
#import "SVProgressHUD.h"
#import "MySingleton.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface LinkBViewController ()

@end

@implementation LinkBViewController

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
    
    //    //本页标题
    //    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, 70, 24)];
    //    titleLabel.textColor = [UIColor whiteColor];
    //    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    //    titleLabel.text = @"呵护血压";
    //    titleLabel.textAlignment = NSTextAlignmentLeft;
    //    [self.view addSubview:titleLabel];
    
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
    NSString *urlString = [[NSString alloc]initWithFormat:@"http://%@/sys/appContent_detailContent?type=0&id=%d",[MySingleton sharedSingleton].serverDomain,[[_dic valueForKey:@"contentId"] intValue]];
    NSURL *url =[NSURL URLWithString:urlString];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

-(void)backBtnPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)passValue : (NSDictionary *)value
{
    _dic = value;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL b;
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
