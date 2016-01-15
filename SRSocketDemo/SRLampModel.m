//
//  SRLampModel.m
//  Limente
//
//  Created by wangwendong on 15/12/31.
//  Copyright © 2015年 sunricher. All rights reserved.
//

#import "SRLampModel.h"

@implementation SRLampModel

#define SRLampModelIndex @"SRLampModelIndex"
#define SRLampModelName @"SRLampModelName"
#define SRLampModelState2 @"SRLampModelState2"
#define SRLampModelBrightness @"SRLampModelBrightness"
#define SRLampModelImage @"SRLampModelImage"

- (instancetype)init {
    self = [super init];
    if (self) {
        self.index = 0;
        self.name = @"Lamp";
        self.state = SRLampModelStateOFF;
        self.brightness = 0.5f;
        UIImage *image = [UIImage imageNamed:@"lamp_base"];
        NSData *imageData = UIImagePNGRepresentation(image);
        self.image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInteger:self.index forKey:SRLampModelIndex];
    [aCoder encodeObject:self.name forKey:SRLampModelName];
    [aCoder encodeInteger:self.state forKey:SRLampModelState2];
    [aCoder encodeFloat:self.brightness forKey:SRLampModelBrightness];
    [aCoder encodeObject:self.image forKey:SRLampModelImage];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.index = [aDecoder decodeIntegerForKey:SRLampModelIndex];
        self.name = [aDecoder decodeObjectForKey:SRLampModelName];
        self.state = [aDecoder decodeIntegerForKey:SRLampModelState2];
        self.brightness = [aDecoder decodeFloatForKey:SRLampModelBrightness];
        self.image = [aDecoder decodeObjectForKey:SRLampModelImage];
    }
    return self;
}

@end
