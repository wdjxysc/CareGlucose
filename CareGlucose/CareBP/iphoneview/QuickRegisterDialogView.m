//
//  QuickRegisterDialogView.m
//  Market
//
//  Created by 夏 伟 on 14-7-1.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "QuickRegisterDialogView.h"

@implementation QuickRegisterDialogView
@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize hadAccountBtn;
@synthesize quickLoginBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //获得nib视图数组
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"QuickRegisterDialogView" owner:self options:nil];
        //得到第一个UIView
        self = [nib objectAtIndex:0];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
