//
//  SRRoomTableViewCellModel.h
//  Limente
//
//  Created by wangwendong on 15/12/28.
//  Copyright © 2015年 sunricher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRLampModel.h"

#define SRRoomTableViewCellHeightDivWidth 0.362f

typedef NS_ENUM(NSInteger, SRRoomModelStandardImageType) {
    SRRoomModelStandardImageTypeLivingRoom = 0x00,
    SRRoomModelStandardImageTypeKitchen = 0x01
};

@interface SRRoomTableViewCellModel : NSObject <NSCopying>

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *image;
@property (nonatomic) BOOL isHighlighted;
@property (nonatomic) NSUInteger index;

@property (strong, nonatomic) NSMutableArray *lamps;

@property (nonatomic, readonly) NSUInteger header; // 0x55
@property (strong, nonatomic) NSData *deviceNumber; // 3 bytes
@property (nonatomic, readonly) NSUInteger deviceType; // 0x01
@property (nonatomic) NSUInteger subdevicesBit; // 子机选择位
@property (nonatomic, readonly) NSUInteger dataType; // 0x08
@property (nonatomic, readonly) NSUInteger keyNubmer; // 0x38
@property (nonatomic) NSUInteger brightness; // 0x01 ~ 0x255

- (CGFloat)heightInTableView:(UITableView *)tableView;

- (void)updateStandardImageType:(SRRoomModelStandardImageType)imageType;

@end
