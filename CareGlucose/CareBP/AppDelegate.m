//
//  AppDelegate.m
//  CareBP
//
//  Created by 夏 伟 on 14-6-28.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//shi

#import "AppDelegate.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    if(iPhone5)
    {
//        _mainViewController = [[MainViewController alloc]initWithNibName:@"MainViewController_4inch" bundle:nil];
//        _historyViewController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
        _loginViewControllerTM = [[LoginViewControllerTM alloc] initWithNibName:@"LoginViewControllerTM_4Inch" bundle:nil];
    }
    else
    {
//        _mainViewController = [[MainViewController alloc]initWithNibName:@"MainViewController" bundle:nil];
//        _historyViewController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
        _loginViewControllerTM = [[LoginViewControllerTM alloc] initWithNibName:@"LoginViewControllerTM" bundle:nil];
    }
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:_loginViewControllerTM];
    navi.navigationBar.hidden = YES;
    _window.rootViewController = navi;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
