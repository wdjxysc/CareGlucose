//
//  BloodPressTableViewCell.m
//  CareBP
//
//  Created by 夏 伟 on 14-7-24.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "BloodPressTableViewCell.h"

@implementation BloodPressTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    _tipsLabel.textColor = [UIColor colorWithRed:117/255.0f green:224/255.0f blue:139/255.0f alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
