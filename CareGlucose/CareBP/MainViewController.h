//
//  MainViewController.h
//  CareBP
//
//  Created by 夏 伟 on 14-6-28.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface MainViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate,UITabBarControllerDelegate,UIAlertViewDelegate>
{
    IBOutlet UIButton *inputDataBtn;
    IBOutlet UIView *contentView;
}

@property(retain,nonatomic)UIView *contentView;

@property int nowid;

@property(retain,nonatomic)UIButton *heartBtn;
@property(retain,nonatomic)UIButton *submitBtn;
@property(retain,nonatomic)UIButton *submitBtnSubBtn;

@property(retain,nonatomic)UIButton *inputDataBtn;

@property(retain,nonatomic)NSDictionary *datadic;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral     *discoveredPeripheral;
@property (strong, nonatomic) CBCharacteristic *writeCharacteristic;
@property (strong, nonatomic) CBCharacteristic *notifyCharacteristic;
@property (strong, nonatomic) CBPeripheral     *targetPeripheral;
@property (nonatomic, strong) NSMutableData    *data;

@property (nonatomic) int lastsys;
@property (nonatomic) int lastdia;
@property (nonatomic) int lastpulse;

-(IBAction)inputDataBtnPressed:(id)sender;

@end
