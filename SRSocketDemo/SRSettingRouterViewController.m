//
//  SRSettingRouterViewController.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/18.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "SRSettingRouterViewController.h"
#import "SRWiFiManager.h"
#import "MBProgressHUD.h"

typedef NS_ENUM(NSInteger, SRWiFiSettingRouterType) {
    SRWiFiSettingRouterTypeNone = 0,
    SRWiFiSettingRouterTypeName = 1,
    SRWiFiSettingRouterTypePassword = 2,
    SRWiFiSettingRouterTypeMode = 3,
    SRWiFiSettingRouterTypeEnd = 4
};

@interface SRSettingRouterViewController () <UITextFieldDelegate, MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) MBProgressHUD *progressHUD;

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

- (BOOL)prefersStatusBarHidden {
    return YES;
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
    if (![SRWiFiManager isWiFiConnected]) {
        _progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _progressHUD.mode = MBProgressHUDModeText;
        _progressHUD.labelText = @"Please connect to device";
        _progressHUD.margin = 10;
        _progressHUD.removeFromSuperViewOnHide = YES;
        _progressHUD.dimBackground = YES;
        
        [_progressHUD hide:YES afterDelay:3];
        
        return;
    }
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_progressHUD];
    
    _progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
    _progressHUD.delegate = self;
    _progressHUD.labelText = @"Setting...";
    _progressHUD.removeFromSuperViewOnHide = YES;
    _progressHUD.dimBackground = YES;
    
    [_progressHUD showWhileExecuting:@selector(handleSetting) onTarget:self withObject:nil animated:YES];
    
    if (_wifiDevice) {
        NSData *nameData = [SRWiFiProtocol srDataForSettingWiFiName:_wifiDevice.name];
        
        _settingRouterType = SRWiFiSettingRouterTypeName;
        [[SRWiFiManager sharedInstance] sendData:nameData withType:SRWiFiManagerConnectTypeUDP times:3 sendTag:SRWiFiManagerSendDataTagForSettingWiFiName timeout:-1];
    }
}

- (void)handleSetting {
    float progress = 0;
    while (progress < 1.0) {
        _progressHUD.progress = progress;
        progress += 0.005;
        usleep(20000);
    }
    
    NSString *text = @"";
    _progressHUD.labelText = text;
    _progressHUD.hidden = YES;
    // Success
    if (_settingRouterType == SRWiFiSettingRouterTypeEnd) {
        text = @"Configure successfully! Please reset WiFi controller";
    } else {
        text = @"WiFi controller Configuration failed，Please reset WiFi controller and reconnect the network";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:text message:nil delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles:nil, nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [hud removeFromSuperview];
    hud = nil;
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
