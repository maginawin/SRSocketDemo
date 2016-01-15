//
//  SRWiFiManager.h
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SRWiFiTCPPort (8899)
#define SRWiFiUDPPort (48899)

typedef NS_ENUM(NSInteger, SRWiFiManagerConnectType) {
    SRWiFiManagerConnectTypeTCP = 0,
    SRWiFiManagerConnectTypeUDP = 1,
    SRWiFiManagerConnectTypeDisconnected = 2
};

typedef NS_ENUM(NSInteger, SRWiFiManagerSendDataTag) {
    SRWiFiManagerSendDataTagForControl = 0,
    SRWiFiManagerSendDataTagForSettingScan = 1,
    SRWiFiManagerSendDataTagForSettingOK = 2,
    SRWiFiManagerSendDataTagForSettingFetchWiFiNearby = 3,
    SRWiFiManagerSendDataTagForSettingWiFiName = 4,
    SRWiFiManagerSendDataTagForSettingWiFiSecurity = 5,
    SRWiFiManagerSendDataTagForSettingMode = 6,
    SRWiFiManagerSendDataTagForSettingEnd = 7
};

typedef void (^ SRWiFiManagerSendReceiver) (NSString *receivedString);

@interface SRWiFiManager : NSObject

@property (nonatomic, readonly) SRWiFiManagerConnectType connectType;

+ (instancetype)sharedInstance;

+ (BOOL)isWiFiConnected;

//- (NSString *)wifiIPAddress;

- (void)disconnectSocket;

- (void)connectTCPWithHost:(NSString *)host port:(NSUInteger)port;

- (void)connectUDPWithPort:(NSUInteger)port;

- (void)sendData:(NSData *)data withType:(SRWiFiManagerConnectType)type times:(NSUInteger)times sendTag:(SRWiFiManagerSendDataTag)tag timeout:(NSInteger)timeout receiver:(SRWiFiManagerSendReceiver)receiver;

@end