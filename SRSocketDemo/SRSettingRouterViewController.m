//
//  SRSettingRouterViewController.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/18.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "SRSettingRouterViewController.h"
#import "SRWiFiManager.h"

@interface SRSettingRouterViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@end

@implementation SRSettingRouterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _passwordTextField.delegate = self;

    if (_wifiDevice) {
        NSString *name = _wifiDevice.name;
        
        if (name) {
            _passwordTextField.placeholder = [NSString stringWithFormat:@"Please input %@'s password", name];
        }
    }
    
    [_passwordTextField becomeFirstResponder];
}

- (IBAction)closeClick:(id)sender {
    [_passwordTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendClick:(id)sender {
    // Send data
    
    [_passwordTextField resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (string.length < 1) {
        if ((textField.text.length - 1) < 1) {
            _sendButton.enabled = NO;
        }
    } else {
        _sendButton.enabled = YES;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    _sendButton.enabled = NO;
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length > 0) {
        [textField resignFirstResponder];
        
        // Send data
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
        return YES;
    } else {
        return NO;
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
