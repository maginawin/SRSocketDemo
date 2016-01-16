//
//  ViewController.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "ViewController.h"
#import "SRWiFiManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *receiveTextView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)udpConnect:(id)sender {
    [[SRWiFiManager sharedInstance] connectUDPWithPort:SRWiFiUDPPort];
}

- (IBAction)udpScan:(id)sender {
    [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingScan] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingScan timeout:-1 receiver:^(NSString *receivedString) {
        
    }];
}

- (IBAction)closeAll:(id)sender {
    [[SRWiFiManager sharedInstance] disconnectSocket];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
