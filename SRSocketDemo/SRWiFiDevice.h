//
//  SRWiFiDevice.h
//  SRSocketDemo
//
//  Created by wangwendong on 16/1/15.
//  Copyright © 2016年 sunricher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SRWiFiDevice : NSObject

@property (strong, nonatomic) NSString *ipAddress;
@property (strong, nonatomic) NSString *macAddrss;
@property (strong, nonatomic) NSString *security;

@end
