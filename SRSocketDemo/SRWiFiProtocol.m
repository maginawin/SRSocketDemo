//
//  SRWiFiProtocol.m
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import "SRWiFiProtocol.h"
#import "SRRoomTableViewCellModel.h"

@implementation SRWiFiProtocol

+ (NSData *)srDataForControlFromRoom:(SRRoomTableViewCellModel *)room {
    if (!room) {
        return nil;
    }
    
    NSMutableData *result = [NSMutableData data];
    
    int header = (int)room.header;
    [result appendBytes:&header length:1];
    [result appendData:room.deviceNumber];
    
    int sum = (int)(room.deviceType + room.subdevicesBit + room.dataType + room.keyNubmer + room.brightness);
    unsigned const char footer[] = {(int)room.deviceType, (int)room.subdevicesBit, (int)room.dataType, (int)room.keyNubmer, (int)room.brightness, sum, 0xAA, 0xAA};
    [result appendBytes:footer length:8];
    
    return result;
}

+ (NSData *)srDataForSettingScan {
    NSData *data = [@"HF-A11ASSISTHREAD" dataUsingEncoding:NSASCIIStringEncoding];
    
    return data;
}

+ (NSData *)srDataForSettingOK {
    NSMutableData *data = [NSMutableData dataWithData:[@"+ok" dataUsingEncoding:NSASCIIStringEncoding]];
    
//    unsigned const char end = 0x0D;
//    
//    [data appendBytes:&end length:1];
    
    return data;
}

+ (NSData *)srDataForSettingFetchWiFiNearby {
    NSMutableData *result = [NSMutableData data];
    
    NSData *header = [@"AT+WSCAN" dataUsingEncoding:NSASCIIStringEncoding];
    [result appendData:header];
    
    unsigned const char end = 0x0D;
    [result appendBytes:&end length:1];
    
    return result;
}

+ (NSData *)srDataForSettingWiFiName:(NSString *)wifiName {
    NSMutableData *result = [NSMutableData data];
    
    
    return result;
}

+ (NSData *)srDataForSettingWiFiSecurity:(NSString *)security password:(NSString *)password {
    NSMutableData *result = [NSMutableData data];
    
    
    return result;
}

+ (NSData *)srDataForSettingMode {
    NSMutableData *result = [NSMutableData data];
    
    
    return result;
}

+ (NSData *)srDataForSettingEnd {
    NSMutableData *result = [NSMutableData data];
    
    
    return result;
}

@end
