//
//  ProblemViewController.h
//  CareBP
//
//  Created by 夏 伟 on 14-7-11.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface QuestionViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property(retain,nonatomic)UITableView *tableView;

@property(retain,nonatomic)NSArray *questionArray;

@end
