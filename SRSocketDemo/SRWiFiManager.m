//
//  SRWiFiManager.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "SRWiFiManager.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface SRWiFiManager ()

@property (strong, nonatomic) GCDAsyncSocket *tcpSocket;
@property (strong, nonatomic) GCDAsyncUdpSocket *udpSocket;

@property (strong, nonatomic) SRWiFiManagerSendReceiver sendReceiver;

@property (strong, nonatomic) NSMutableDictionary<NSNumber *, NSString *> *receiverDictionary;

@end

@implementation SRWiFiManager

+ (instancetype)sharedInstance {
    static id instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
        [instance setupDidInit];
    });
    
    return instance;
}

+ (BOOL)isWiFiConnected {
    NSString *wifiName = [SRWiFiManager getWiFiName];
    
    if (wifiName.length < 1) {
        return NO;
    } else {
        return YES;
    }
}

- (void)connectTCPWithHost:(NSString *)host port:(NSUInteger)port {
    
}

- (void)disconnectSocket {
    
}

+ (NSString *)getWiFiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    
    NSLog(@"wifiName %@", wifiName);
    
    return wifiName;
}

#pragma mark - ------- Private -------

- (void)setupDidInit {
    _receiverDictionary = [NSMutableDictionary dictionary];
}

@end
