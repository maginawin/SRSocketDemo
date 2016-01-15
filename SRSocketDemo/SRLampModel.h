//
//  SRLampModel.h
//  Limente
//
//  Created by wangwendong on 15/12/31.
//  Copyright © 2015年 sunricher. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SRLampModelState) {
    SRLampModelStateOFF = 0,
    SRLampModelStateON = 1
};

@interface SRLampModel : NSObject <NSCoding>

@property (nonatomic) NSUInteger index;
@property (strong, nonatomic) NSString *name;
@property (nonatomic) SRLampModelState state;
@property (nonatomic) CGFloat brightness;
@property (strong, nonatomic) UIImage *image;

@end
