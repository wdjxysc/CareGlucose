//
//  MainViewController.m
//  CareBP
//
//  Created by 夏 伟 on 14-6-28.
//  Copyright (c) 2014年 夏 伟. All rights reserved.
//

#import "MainViewController.h"
#import "ServerConnect.h"
#import "LinkAViewController.h"
#import "LinkBViewController.h"
#import "QuestionViewController.h"
#import "MySingleton.h"
#import "NSDate+Additions.h"
#import "Regex.h"

#define TRANSFER_SERVICE_UUID               @"fff0"
#define TRANSFER_NOTIFYCHARACTERISTIC_UUID  @"fff4"
#define TRANSFER_WRITECHARACTERISTIC_UUID   @"fff3"
#define DEVICE_NAME                         @"eBlood-Pressure"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define Screen_height   [[UIScreen mainScreen] bounds].size.height
#define Screen_width    [[UIScreen mainScreen] bounds].size.width

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *sysLabel;
@property (weak, nonatomic) IBOutlet UITextField *sysTextField;
@property (weak, nonatomic) IBOutlet UILabel *sysUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *diaLabel;
@property (weak, nonatomic) IBOutlet UITextField *diaTextField;
@property (weak, nonatomic) IBOutlet UILabel *diaUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *pulseLabel;
@property (weak, nonatomic) IBOutlet UITextField *pulseTextField;
@property (weak, nonatomic) IBOutlet UILabel *pulseUnitLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel1;
@property (weak, nonatomic) IBOutlet UIImageView *imageView2;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel2;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView2;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn1;
@property (weak, nonatomic) IBOutlet UIButton *linkBtn2;
@property (weak, nonatomic) IBOutlet UILabel *inputedDataLabel;
@end

@implementation MainViewController
@synthesize contentView;
@synthesize inputDataBtn;

#define  APPTYPE  2

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}
-(void)tapBgView
{
    // 发送resignFirstResponder.
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initMyView];
    self.tabBarController.delegate = self;
    
//    // Start up the CBCentralManager
//    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
//    // And somewhere to store the incoming data
//    self.data = [[NSMutableData alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //随机得到一个id号
        _nowid = 1;
        NSDictionary *dic = [ServerConnect terminalGetContent:APPTYPE number:_nowid bloodvalue:10.0];
        if(dic)
        {
            _datadic = dic;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (dic) {
                [self loadContentImageView:_datadic];
            }
            else
            {
                NSLog(@"加载失败");
            }
        });
    });
    
    //获取服务器数据
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [ServerConnect getGlucoseDataFromCloud:[[NSDate date] dateByAddingDays:-356]];//近一年数据
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
        });
    });
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [self.centralManager stopScan];
//    [self cleanup];
}
-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![viewController.childViewControllers[0] isKindOfClass:[MainViewController class]]) {
            if(self.centralManager){
                [self cleanup];
                self.centralManager = nil;
            }
        }
        else
        {
            NSLog(@"MainViewController selected!");
            // Start up the CBCentralManager
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            // And somewhere to store the incoming data
            self.data = [[NSMutableData alloc] init];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    });
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    // Start up the CBCentralManager
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    // And somewhere to store the incoming data
    self.data = [[NSMutableData alloc] init];
    
    //    self.image.hidden = NO;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMyView
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgView)];
    [self.view addGestureRecognizer:tap];
    
    [self.view setBackgroundColor:[UIColor colorWithRed:233/255.0f green:234/255.0f blue:236/255.0f alpha:1.0]];
    
    //设置状态栏字体颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //本页标题图片
    UIImageView *topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 64)];
    [topImageView setImage:[UIImage imageNamed:@"navibar_bg"]];
    [self.view addSubview:topImageView];
    
    //本页标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 30, 100, 24)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"Helvetica" size:17];
    titleLabel.text = @"呵护血糖";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    //日期
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 25, 70, 20)];
    dateLabel.textColor = [UIColor whiteColor];
    dateLabel.font = [UIFont fontWithName:@"Helvetica" size:13];
    NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
    [fomatter setDateFormat:@"yyyy/M/d"];
    dateLabel.text = [fomatter stringFromDate:[NSDate date]];
    dateLabel.textAlignment = NSTextAlignmentRight;
//    [self.view addSubview:dateLabel];
    
    //星期
    UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 37, 70, 20)];
    weekLabel.textColor = [UIColor whiteColor];
    weekLabel.font = [UIFont fontWithName:@"Helvetica" size:10];
    NSDateComponents *comps;
    NSCalendar*calendar = [NSCalendar currentCalendar];
    comps =[calendar components:(NSWeekCalendarUnit | NSWeekdayCalendarUnit |NSWeekdayOrdinalCalendarUnit)
                       fromDate:[NSDate date]];
    int i= (int)[comps weekday];
    switch (i) {
        case 1:
            weekLabel.text = @"星期日";
            break;
        case 2:
            weekLabel.text = @"星期一";
            break;
        case 3:
            weekLabel.text = @"星期二";
            break;
        case 4:
            weekLabel.text = @"星期三";
            break;
        case 5:
            weekLabel.text = @"星期四";
            break;
        case 6:
            weekLabel.text = @"星期五";
            break;
        case 7:
            weekLabel.text = @"星期六";
            break;
        default:
            break;
    }
    weekLabel.textAlignment = NSTextAlignmentRight;
//    [self.view addSubview:weekLabel];
    
    //右心
    _heartBtn = [[UIButton alloc]initWithFrame:CGRectMake(290, 32, 21, 17)];
    [_heartBtn setBackgroundImage:[UIImage imageNamed:@"heart"] forState:UIControlStateNormal];
    [_heartBtn addTarget:self action:@selector(careBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_heartBtn];
    
    //提交按钮
    _submitBtn = [[UIButton alloc]initWithFrame:CGRectMake(292, 32, 17, 17)];
    _submitBtn.hidden = YES;
    [_submitBtn setBackgroundImage:[UIImage imageNamed:@"submit"] forState:UIControlStateNormal];
    [_submitBtn addTarget:self action:@selector(submitBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtn];
    _submitBtnSubBtn = [[UIButton alloc]initWithFrame:CGRectMake(270, 20, 44, 44)];
    [_submitBtnSubBtn addTarget:self action:@selector(submitBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_submitBtnSubBtn];
    
    
    _imageView1.image = [UIImage imageNamed:@"image1"];
    _imageView2.image = [UIImage imageNamed:@"image2"];
    
    
    //scrollView
    CGRect scrollViewFrame = CGRectMake(0, 64, 320, 367);
    if(iPhone5)
    {
        scrollViewFrame = CGRectMake(0, 64, 320, 455);
    }
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    scrollView.contentSize = CGSizeMake(contentView.frame.size.width, contentView.frame.size.height);
    [scrollView addSubview:contentView];
    [self.view addSubview:scrollView];
}

-(IBAction)inputDataBtnPressed:(id)sender
{
//    _sysLabel.hidden = NO;
//    _sysTextField.hidden = NO;
//    _sysUnitLabel.hidden = NO;
    _diaLabel.hidden = NO;
    _diaTextField.hidden = NO;
    _diaUnitLabel.hidden = NO;
//    _pulseLabel.hidden = NO;
//    _pulseTextField.hidden = NO;
//    _pulseUnitLabel.hidden = NO;
    UIButton *btn = (UIButton *)sender;
    btn.hidden = YES;
    
    _heartBtn.hidden = YES;
    _submitBtn.hidden = NO;
    _submitBtnSubBtn.hidden = NO;
    _inputedDataLabel.hidden = YES;
}

-(void)loadContentImageView : (NSDictionary *)dic
{
    NSLog(@"%@",dic);
    if(([[dic valueForKey:@"RESULT_CODE"] intValue] == 0) &&([dic count] != 0))
    {
        _titleLabel1.text = [[[dic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_YF"] valueForKey:@"conetentTitle"];
        _contentLabel1.text = [[[dic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_YF"] valueForKey:@"contentSummary"];
        
        _titleLabel2.text = [[[dic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_FA"] valueForKey:@"typeName"];
        _contentLabel2.text = [[[dic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_FA"] valueForKey:@"conetentTitle"];
        _contentTextView2.text = [[[dic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_FA"] valueForKey:@"contentSummary"];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSData *dataimage_fa = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[dic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_FA"] valueForKey:@"thumbnailUrl"]]];//适用于加载在网页上的图片
        //        NSData *data = [ServerConnect doSyncRequest:[rowData valueForKey:@"imageName"]];//用于下载图片
        UIImage *image_fa = [UIImage imageWithData:dataimage_fa];
        NSData *dataimage_yf = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[[dic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_YF"] valueForKey:@"thumbnailUrl"]]];//适用于加载在网页上的图片
        //        NSData *data = [ServerConnect doSyncRequest:[rowData valueForKey:@"imageName"]];//用于下载图片
        UIImage *image_yf = [UIImage imageWithData:dataimage_yf];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image_fa)
            _imageView1.image = image_fa;
            if (image_yf)
            _imageView2.image = image_yf;
        });
    });
}

-(IBAction)submitBtnPressed:(id)sender
{
    _sysLabel.hidden = YES;
    _sysTextField.hidden = YES;
    _sysUnitLabel.hidden = YES;
    _diaLabel.hidden = YES;
    _diaTextField.hidden = YES;
    _diaUnitLabel.hidden = YES;
    _pulseLabel.hidden = YES;
    _pulseTextField.hidden = YES;
    _pulseUnitLabel.hidden = YES;
    inputDataBtn.hidden = NO;
    
    
    _submitBtn.hidden = YES;
    _submitBtnSubBtn.hidden = YES;
    _heartBtn.hidden = NO;
    
    [self tapBgView];
    
    
    
    if([Regex validatePositiveFloat:_diaTextField.text]||[Regex validatePositiveInteger:_diaTextField.text])
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            _nowid = (_nowid+1)%5;
            if(_nowid == 0)
            {
                _nowid = 1;
            }
            NSDictionary *dic = [ServerConnect terminalGetContent:APPTYPE number:_nowid bloodvalue:[_diaTextField.text floatValue]];
            if(dic)
            {
                _datadic = dic;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (dic) {
                    [self loadContentImageView:_datadic];
                }
                else
                {
                    NSLog(@"ServerConnect terminalGetContent failed");
                }
            });
        });
        
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[[NSString alloc] initWithFormat:@"%f",[_diaTextField.text floatValue]] forKey:@"Glucose"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *datestr = [formatter stringFromDate:[NSDate date]];
        [dic setObject:datestr forKey:@"TestTime"];
        
        NSThread* myThread2 = [[NSThread alloc] initWithTarget:self selector:@selector(uploadGlucoseData:)object:dic];
        [myThread2 start];
        
        
        _inputedDataLabel.text = [[NSString alloc] initWithFormat:@"血糖: %@ mmol/L",_diaTextField.text];
        _inputedDataLabel.hidden = NO;
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"输入数值必须是正数" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.delegate = self;
        [alertView show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _diaTextField.text = @"";
}

-(IBAction)linkBtn1Pressed:(id)sender
{
    LinkAViewController *linkAViewController = [[LinkAViewController alloc]initWithNibName:@"LinkAViewController" bundle:nil];
    NSMutableDictionary *value = [[_datadic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_YF"];
    [linkAViewController passValue:value];
    [self.navigationController pushViewController:linkAViewController animated:YES];
}
-(IBAction)linkBtn2Pressed:(id)sender
{
    LinkBViewController *linkBViewController = [[LinkBViewController alloc]initWithNibName:@"LinkBViewController" bundle:nil];
    NSMutableDictionary *value = [[_datadic valueForKey:@"RESULT_INFO"] valueForKey:@"RESULT_FA"];
    [linkBViewController passValue:value];
    [self.navigationController pushViewController:linkBViewController animated:YES];
}
-(IBAction)careBtnPressed:(id)sender
{
    QuestionViewController *questionViewController = [[QuestionViewController alloc]initWithNibName:@"QuestionViewController" bundle:nil];
    [self.navigationController pushViewController:questionViewController animated:YES];
}

///corebluetooth

#pragma mark - Central Methods



/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    [self scan];
    
}

/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}


/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Reject any where the value is above reasonable range
    
    //    if (RSSI.integerValue > -15) {
    //        return;
    //    }
    //
    //    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
    //    if (RSSI.integerValue < -35) {
    //        return;
    //    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    for(int i = 0;i < sizeof(peripheral.services);i++)
    {
        NSLog(@"%@",peripheral.services[i]);
    }
    
    
    // Ok, it's in range - have we already seen it?
    if([peripheral.name isEqual: @"eBlood-Pressure"])
    {
        if (self.discoveredPeripheral != peripheral) {
            
            // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
            self.discoveredPeripheral = peripheral;
            
            // And connect
            NSLog(@"Connecting to  %@", peripheral);
            [self.centralManager connectPeripheral:peripheral options:nil];
            
            //设置图片消失
//            image.hidden = true;
        }
    }
}

/** If the connection fails for whatever reason, we need to deal with it.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}


/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
//    _btImage.image = [UIImage imageNamed:@"ly"];
    // Stop scanning
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    // Clear the data that we may already have
    [self.data setLength:0];
    
    // Make sure we get the discovery callbacks
    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    int i = sizeof(peripheral.services);
    NSLog(@"共有服务%d个",i);
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        NSLog(@"Service found with UUID: %@",service.UUID);
        // Discovers the characteristics for a given service
        
        if ([service.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]])
        {
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_NOTIFYCHARACTERISTIC_UUID]] forService:service];
            [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_WRITECHARACTERISTIC_UUID]] forService:service];
        }
        //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]] forService:service];
    }
}


/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        //        [self cleanup];
        //        return;
    }
    
    CBCharacteristic *readcharacteristic;
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        NSLog(@"特征:%@",characteristic.UUID);
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_NOTIFYCHARACTERISTIC_UUID]]) {
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            
//            readcharacteristic = characteristic;
            _notifyCharacteristic = characteristic;
            //TRANSFER_WRITECHARACTERISTIC_UUID
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_WRITECHARACTERISTIC_UUID]])
        {
            Byte weighthigh,weightlow,sportlvl,genderage,height;
            NSString *weightstr = [[MySingleton sharedSingleton].nowuserinfo objectForKey:@"Weight"];
            double weight = [weightstr doubleValue];
            weighthigh = ((int)(weight*10))/256;
            weightlow = ((int)(weight*10))%256;
            weighthigh += 64;
            NSString *sportlvlstr = [[MySingleton sharedSingleton].nowuserinfo objectForKey:@"Profesion"];
            if([sportlvlstr isEqualToString:@""]||sportlvlstr == nil)
            {
                sportlvl = 0;
            }
            else
            {
                //服务网是0，1，2等级  设备是1，2，3等级
                sportlvl = [sportlvlstr intValue] + 1;
            }
            
            NSString *sexstr = [[MySingleton sharedSingleton].nowuserinfo objectForKey:@"Sex"];
            NSDateFormatter* dateFormat = [[NSDateFormatter alloc] init];//实例化一个NSDateFormatter对象
            [dateFormat setDateFormat:@"yyyy-MM-dd"];//设定时间格式,这里可以设置成自己需要的格式
            //            NSDate *birthdate =[dateFormat dateFromString:[[NSString alloc]initWithFormat:@"%@",[[MySingleton sharedSingleton].nowuserinfo objectForKey:@"Brithday"]]];
            //            Byte age = [self GetAgeByBrithday:brithdate];
            NSString *agestr = [[MySingleton sharedSingleton].nowuserinfo objectForKey:@"Age"];
            Byte age = [agestr intValue];
            
            
            //性别代码 服务网 0男，1女  设备0女，1男
            if([sexstr isEqualToString:@"0"])
            {
                genderage =  age + 0x80;
            }
            else
            {
                genderage = age;
            }
            
            height = [[[MySingleton sharedSingleton].nowuserinfo objectForKey:@"Height"] intValue];
            
            sleep(3);
            Byte setUserInfo[] = {0xfd,0x53,weighthigh,weightlow,sportlvl,genderage,height};
            NSData *testData = [[NSData alloc]initWithBytes:setUserInfo length:sizeof(setUserInfo)];
            [peripheral writeValue:testData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            NSLog(@"write value %@ ---- 0x02,0x20,0xdd,0x02,0xfd,0x29,0xd4",[CBUUID UUIDWithString:TRANSFER_NOTIFYCHARACTERISTIC_UUID]);
            _writeCharacteristic = characteristic;
            //            [peripheral readValueForCharacteristic:characteristic];
            //            NSData *revData = characteristic.value;
            //            Byte *revbyte = (Byte *)[revData bytes];
            //            int size = sizeof(revbyte);
            //            NSLog(@"revData Length:%d",size);
            //            for(int i = 0; i<sizeof(revbyte);i++)
            //            {
            //                NSLog(@"revdata:%d",revbyte[i]);
            //            }
        }
    }
    
    //[peripheral readValueForCharacteristic:readcharacteristic];
    //NSLog(@"readcharacteristic.UUID:%@",readcharacteristic.UUID);
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    self.targetPeripheral = peripheral;
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    NSData *lol = characteristic.value;
    Byte *revdata = (Byte *)[lol bytes];
    for(int i = 0;i<[lol length];i++)
    {
        NSLog(@"收到字节：%d",revdata[i]);
    }
    
    //收到测量中数据
    if([lol length]==2)
    {
        _sysTextField.text = [[NSString alloc] initWithFormat:@"%d",revdata[1]];
        _diaTextField.text = @"0";
        _pulseTextField.text = @"0";
    }
    
    //收到确定数据
    if([lol length]==12)
    {
        int sysdata = revdata[1]*256 +revdata[2];
        int diadata = revdata[3]*256 + revdata[4];
        int pulsedata = revdata[7]*256+ revdata[8];
        
        _sysTextField.text = [[NSString alloc]initWithFormat:@"%d",sysdata];
        _diaTextField.text = [[NSString alloc]initWithFormat:@"%d",diadata];
        _pulseTextField.text = [[NSString alloc]initWithFormat:@"%d",pulsedata];
        
        
        //        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        //        NSString *testTime = [dateFormatter stringFromDate:date];
        
        
        //if (!(sysdata == lastsys && diadata == lastdia && pulsedata ==  lastpulse )) {
        
        _lastsys = sysdata;
        _lastdia = diadata;
        _lastpulse = pulsedata;
        
        
        //}
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        [dic setObject:[[NSString alloc] initWithFormat:@"%d",sysdata] forKey:@"SYS"];
        [dic setObject:[[NSString alloc] initWithFormat:@"%d",diadata] forKey:@"DIA"];
        [dic setObject:[[NSString alloc] initWithFormat:@"%d",pulsedata] forKey:@"Pulse"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *datestr = [formatter stringFromDate:[NSDate date]];
        [dic setObject:datestr forKey:@"TestTime"];
        
        NSThread* myThread2 = [[NSThread alloc] initWithTarget:self selector:@selector(uploadGlucoseData:)object:dic];
        [myThread2 start];
    }
    
    //    Byte getData[] = {0xfd,0x31};
    //    NSData *testData = [[NSData alloc]initWithBytes:getData length:sizeof(getData)];
    //    [self.targetPeripheral writeValue:testData forCharacteristic:writeCharacteristic type:CBCharacteristicWriteWithResponse];
    //    [self.targetPeripheral writeValue:testData forDescriptor:nil];
    NSLog(@"write value 0x02,0x20,0xdd,0x02,0xfd,0x30,0xd4");
    
    
    
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        // We have, so show the data,
        //[self.textview setText:[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]];
        NSLog(@"GetDataValue : %@",[[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding]);
        // Cancel our subscription to the characteristic
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    // Otherwise, just add the data on to what we already have
    [self.data appendData:characteristic.value];
    
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
}



/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_NOTIFYCHARACTERISTIC_UUID]]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    
//    _btImage.image = [UIImage imageNamed:@"ly0"];
    // We're disconnected, so start scanning again
    [self scan];
}


/** Call this when things either go wrong, or you're done with the connection.
 *  This cancels any subscriptions if there are any, or straight disconnects if not.
 *  (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved)
 */
- (void)cleanup
{
    // Don't do anything if we're not connected
    if (self.discoveredPeripheral.state == CBPeripheralStateDisconnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_NOTIFYCHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            // It is notifying, so unsubscribe
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            // And we're done.
                            return;
                        }
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}


-(void)uploadGlucoseData:(NSMutableDictionary *)datadic
{
    NSDictionary *resultdic = [ServerConnect uploadGlucoseData:datadic authkey:[[MySingleton sharedSingleton].nowuserinfo valueForKey:@"AuthKey"]];
    NSLog(@"%@",resultdic);
    
    [ServerConnect getGlucoseDataFromCloud:[[NSDate date] dateByAddingDays:-356]];
}

@end
