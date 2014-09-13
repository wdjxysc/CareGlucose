//
//  AppDelegate.h
//  CareBP
//
//  Created by 夏 伟 on 14-6-28.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "HistoryViewController.h"
#import "LoginViewControllerTM.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainViewController *mainViewController;
@property (strong, nonatomic) HistoryViewController *historyViewController;
@property (strong, nonatomic) LoginViewControllerTM *loginViewControllerTM;
@end
