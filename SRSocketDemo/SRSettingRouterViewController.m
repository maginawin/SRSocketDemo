//
//  SRSettingRouterViewController.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/18.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "SRSettingRouterViewController.h"
#import "SRWiFiManager.h"

typedef NS_ENUM(NSInteger, SRWiFiSettingRouterType) {
    SRWiFiSettingRouterTypeNone = 0,
    SRWiFiSettingRouterTypeName = 1,
    SRWiFiSettingRouterTypePassword = 2,
    SRWiFiSettingRouterTypeMode = 3,
    SRWiFiSettingRouterTypeEnd = 4
};

@interface SRSettingRouterViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (nonatomic) SRWiFiSettingRouterType settingRouterType;

@end

@implementation SRSettingRouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _settingRouterType = SRWiFiSettingRouterTypeNone;
    
    _passwordTextField.delegate = self;

    if (_wifiDevice) {
        NSString *name = _wifiDevice.name;
        
        if (name) {
            _passwordTextField.placeholder = [NSString stringWithFormat:@"Please input %@'s password", name];
        }
    }
    
    [_passwordTextField becomeFirstResponder];
    
    // Set notification
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleWiFiManagerNotiUDPReceiveData:) name:SRWiFiManagerNotiUDPReceiveData object:nil];
}

- (void)handleWiFiManagerNotiUDPReceiveData:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^ {
        NSData *data = noti.object;
        
        if (data) {
            NSString *receiveString = [NSString stringWithUTF8String:data.bytes];
            
            if (receiveString.length > 8) {
                NSString *tag0String = [receiveString substringToIndex:8];
                
                if ([tag0String isEqualToString:@"AT+WSKEY"]) {
                    if (_settingRouterType == SRWiFiSettingRouterTypePassword) {
                        _settingRouterType = SRWiFiSettingRouterTypeMode;
                        [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingMode] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingMode timeout:-1];
                    }
                } else if ([tag0String isEqualToString:@"AT+WSSSI"]) {
                    if (_settingRouterType == SRWiFiSettingRouterTypeName) {
                        _settingRouterType = SRWiFiSettingRouterTypePassword;
                        [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingWiFiSecurity:_wifiDevice.security password:_passwordTextField.text] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingWiFiSecurity timeout:-1];
                    }
                }
            }
            
            if (receiveString.length >= 3) {
                NSString *tag1String = [receiveString substringToIndex:3];
                
                if ([tag1String isEqualToString:@"+ok"]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (_settingRouterType == SRWiFiSettingRouterTypeMode) {
                            _settingRouterType = SRWiFiSettingRouterTypeEnd;
                            [[SRWiFiManager sharedInstance] sendData:[SRWiFiProtocol srDataForSettingEnd] withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingWiFiSecurity timeout:-1];
                        }
                    });
                }
            }
        }
    });
}

- (IBAction)closeClick:(id)sender {
    [_passwordTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendClick:(id)sender {
    // Send data
    [self sendData];
    
    [_passwordTextField resignFirstResponder];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    [textField resignFirstResponder];
    
    // Send data
    [self sendData];
    
//        [self dismissViewControllerAnimated:YES completion:nil];

    return YES;
}

- (void)sendData {
    if (_wifiDevice) {
        NSData *nameData = [SRWiFiProtocol srDataForSettingWiFiName:_wifiDevice.name];
        
        _settingRouterType = SRWiFiSettingRouterTypeName;
        [[SRWiFiManager sharedInstance] sendData:nameData withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingWiFiName timeout:-1];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
        });
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
