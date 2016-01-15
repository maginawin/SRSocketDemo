//
//  SRWiFiProtocol.h
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SRRoomTableViewCellModel;

@interface SRWiFiProtocol : NSObject

+ (NSData *)srDataForControlFromRoom:(SRRoomTableViewCellModel *)room;

+ (NSData *)srDataForSettingScan;

+ (NSData *)srDataForSettingOK;

+ (NSData *)srDataForSettingFetchWiFiNearby;

+ (NSData *)srDataForSettingWiFiName:(NSString *)wifiName;

+ (NSData *)srDataForSettingWiFiSecurity:(NSString *)security password:(NSString *)password;

+ (NSData *)srDataForSettingMode;

+ (NSData *)srDataForSettingEnd;

@end
