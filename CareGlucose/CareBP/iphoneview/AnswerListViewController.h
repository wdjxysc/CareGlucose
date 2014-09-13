//
//  AnswerListViewController.h
//  CareBP
//
//  Created by 夏 伟 on 14-7-30.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(retain,nonatomic)UITableView *tableView;

@property(retain,nonatomic)NSArray *answerArray;
@property(retain,nonatomic)NSDictionary *questionDic;

-(void)passValue:(NSDictionary *)value;
@end
