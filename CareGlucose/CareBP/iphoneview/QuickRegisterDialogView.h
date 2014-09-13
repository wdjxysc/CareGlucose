//
//  QuickRegisterDialogView.h
//  Market
//
//  Created by 夏 伟 on 14-7-1.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface QuickRegisterDialogView : UIView
{
    IBOutlet UIButton *hadAccountBtn;
    IBOutlet UILabel *passwordLabel;
    IBOutlet UILabel *usernameLabel;
    IBOutlet UIButton *quickLoginBtn;
}
@property (strong, nonatomic) UIButton *hadAccountBtn;
@property (strong, nonatomic) UILabel *passwordLabel;
@property (strong, nonatomic) UILabel *usernameLabel;
@property (strong, nonatomic) UIButton *quickLoginBtn;

@end