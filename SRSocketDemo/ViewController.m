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

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *receiveTextView;
@property (weak, nonatomic) IBOutlet UITextField *brightnessTextField;
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;

@property (nonatomic) BOOL isOneByOne;

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
    
    __weak typeof(self) weakSelf = self;
    [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingScan] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingScan timeout:-1 receiver:^(NSString *receivedString) {
        
        weakSelf.ipLabel.text = @"null";
        
        if (!receivedString) {
            return; 
        }
        
        NSArray *recComponents = [receivedString componentsSeparatedByString:@","];
        
        NSString *ipAddress = recComponents.firstObject;
        
        if ([ipAddress isEqualToString:@"10.10.100.254"]) {
            weakSelf.isOneByOne = YES;
        } else {
            weakSelf.isOneByOne = NO;
        }
        
        weakSelf.ipLabel.text = ipAddress;
        
        NSLog(@"vc rec: %@, is one by one: %d", receivedString, _isOneByOne);
        
        weakSelf.receiveTextView.text = receivedString;
    }];
}

- (IBAction)closeAll:(id)sender {
    [[SRWiFiManager sharedInstance] disconnectSocket];
}

- (IBAction)connectTCP:(id)sender {
    [[SRWiFiManager sharedInstance] disconnectSocket];
    
    if (_isOneByOne) {
        [[SRWiFiManager sharedInstance] connectTCPWithHost:@"10.10.100.254" port:SRWiFiTCPPort];
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
            
            [[SRWiFiManager sharedInstance] sendData:data withType:SRWiFiManagerConnectTypeTCP times:3 sendTag:SRWiFiManagerSendDataTagForControl timeout:-1 receiver:^(NSString *receivedString) {
                
            }];
            
            NSLog(@"data %@", data);
        }
    }
}


#pragma mark - ------- Private -------

- (void)setupDidInit {
    _isOneByOne = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
