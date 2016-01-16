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
