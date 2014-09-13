//
//  BloodPressTableViewCell.h
//  CareBP
//
//  Created by 夏 伟 on 14-7-24.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodPressTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *yuanImageViw;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sysDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *diaDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *pulseDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@end
