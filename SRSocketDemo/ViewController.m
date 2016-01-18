//
//  ViewController.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "ViewController.h"
#import "SRWiFiManager.h"
#import "SRRoomTableViewCellModel.h"
#import "SRSettingRouterViewController.h"

typedef NS_ENUM(NSInteger, SRWiFiManagerScanType) {
    SRWiFiManagerScanTypeDefault = 0, // Use for scan UDP host
    SRWiFiManagerScanTypeNearbyWiFi = 1 // Use for scan wifi nearby
};

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *brightnessTextField;
@property (weak, nonatomic) IBOutlet UITableView *deviceTableView;

@property (strong, nonatomic) NSMutableDictionary<NSString *, SRWiFiDevice *> *scanDevicesDictionary;
@property (strong, nonatomic) NSMutableArray<SRWiFiDevice *> *scanDevicesArray;

@property (nonatomic) SRWiFiManagerScanType scanType;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupDidInit];
}

- (IBAction)udpConnect:(id)sender {
    [[SRWiFiManager sharedInstance] connectUDPWithPort:SRWiFiUDPPort];
}

- (IBAction)udpScan:(id)sender {
    _scanType = SRWiFiManagerScanTypeDefault;
    
    [[SRWiFiManager sharedInstance].wifiDevicesDictionary removeAllObjects];
    
    [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingScan] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingScan timeout:-1];
}

- (IBAction)scanWiFiNearby:(id)sender {
    _scanType = SRWiFiManagerScanTypeNearbyWiFi;
    
    [[SRWiFiManager sharedInstance].wifiDevicesDictionary removeAllObjects];
    
    NSData *data = [SRWiFiProtocol srDataForSettingScan].copy;
    
    for (int i = 0; i < 30; i++) {
         [[SRWiFiManager sharedInstance] sendData:data withType:SRWiFiManagerConnectTypeUDP times:1 sendTag:SRWiFiManagerSendDataTagForSettingScan timeout:-1];
        
        if (i == 29) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingOK] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingOK timeout:-1];
            });
        }
    }
}

- (IBAction)closeAll:(id)sender {
    [[SRWiFiManager sharedInstance] disconnectSocket];
}

- (IBAction)connectTCP:(id)sender {
    [[SRWiFiManager sharedInstance] disconnectSocket];
    
    NSMutableArray<SRWiFiDevice *> *wifiDevices = [SRWiFiManager sharedInstance].wifiDevicesDictionary.mutableCopy;
    
    for (NSString *host in wifiDevices) {
        if (host.length > 0) {
            [[SRWiFiManager sharedInstance] connectTCPWithHost:host port:SRWiFiTCPPort];
        }
    }
}

- (IBAction)sendTCP:(id)sender {
    if ([SRWiFiManager sharedInstance].connectType == SRWiFiManagerConnectTypeTCP) {
        NSString *dataString = _brightnessTextField.text;
        
        if (dataString.length > 0) {
            SRRoomTableViewCellModel *room = [[SRRoomTableViewCellModel alloc] init];
            unsigned const char deviceNumberBytes[] = {0x00, 0x01, 0x02};
            room.deviceNumber = [NSData dataWithBytes:deviceNumberBytes length:3];
            room.subdevicesBit = 0x01;
            room.brightness = dataString.integerValue;
            NSData *data = [SRWiFiProtocol srDataForControlFromRoom:room];
            
            [[SRWiFiManager sharedInstance] sendData:data withType:SRWiFiManagerConnectTypeTCP times:3 sendTag:SRWiFiManagerSendDataTagForControl timeout:-1];
            
            NSLog(@"data %@", data);
        }
    }
}


#pragma mark - ------- Private -------

- (void)setupDidInit {
    _scanType = SRWiFiManagerScanTypeDefault;
    _scanDevicesDictionary = [NSMutableDictionary dictionary];
    _scanDevicesArray = [NSMutableArray array];

    [self setupNotification];
    
    _deviceTableView.dataSource = self;
    _deviceTableView.delegate = self;
}

- (void)setupNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WiFiManagerNotiUDPReceiveData:) name:SRWiFiManagerNotiUDPReceiveData object:nil];
}

- (void)WiFiManagerNotiUDPReceiveData:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSData *data = noti.object;
        
        if (!data) {
            return;
        }
        
        NSString *dataString = [NSString stringWithCString:data.bytes encoding:NSUTF8StringEncoding];
        
        if (!dataString) {
            return;
        }
        
        SRWiFiDevice *device = [SRWiFiManager convertReceiveStringToWiFiDevice:dataString];
        
        if (device.macAddrss) {
            [_scanDevicesDictionary setObject:device forKey:device.macAddrss];
            
            [self refreshDeviceArray];
            
            [_deviceTableView reloadData];
            
            return;
        }
        
        if ([@"+ok" isEqualToString:dataString]) {
            if (_scanType == SRWiFiManagerScanTypeNearbyWiFi) {
                [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingFetchWiFiNearby] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingFetchWiFiNearby timeout:-1];
                
                _scanType = SRWiFiManagerScanTypeDefault;
            }
            
            return;
        }
        
        NSArray *dataStringComponents = [dataString componentsSeparatedByString:@","];
        
        if (dataStringComponents.count == 3) {
            
            NSString *ipAddress = dataStringComponents.firstObject;
            
            if (ipAddress.length > 0) {
                SRWiFiDevice *wifiDevice = [[SRWiFiDevice alloc] init];
                wifiDevice.ipAddress = ipAddress;
                
                [[SRWiFiManager sharedInstance].wifiDevicesDictionary setObject:wifiDevice forKey:ipAddress];
            }
        }
    });
}

- (void)refreshDeviceArray {
    if (_scanDevicesArray.count != _scanDevicesDictionary.count) {
        [_scanDevicesArray removeAllObjects];
        
        for (NSString *key in _scanDevicesDictionary) {
            SRWiFiDevice *device = _scanDevicesDictionary[key];
            
            [_scanDevicesArray addObject:device];
        }
    }
}

#pragma mark - UITableViewDataSource, UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SRWiFiDevice *device = _scanDevicesArray[indexPath.row];
    
    SRSettingRouterViewController *settingRouterVC = [[SRSettingRouterViewController alloc] initWithNibName:@"SRSettingRouterViewController" bundle:nil];
    settingRouterVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    if (device) {
        settingRouterVC.wifiDevice = device;
    }
    
    [self presentViewController:settingRouterVC animated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _scanDevicesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *deviceTableViewCellIdentifier = @"deviceTableViewCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:deviceTableViewCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:deviceTableViewCellIdentifier];
    }
    
    SRWiFiDevice *device = _scanDevicesArray[indexPath.row];
    
    if (device) {
        cell.textLabel.text = device.name ? device.name : @"null";
        cell.detailTextLabel.text = device.security ? device.security : @"null";
    }
    
    return cell;
}

@end
