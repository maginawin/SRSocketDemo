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
    NSMutableData *data = [NSMutableData dataWithData:[@"+OK" dataUsingEncoding:NSASCIIStringEncoding]];
    
    unsigned const char end = 0x0D;
    
    [data appendBytes:&end length:1];
    
    return data;
}

@end
