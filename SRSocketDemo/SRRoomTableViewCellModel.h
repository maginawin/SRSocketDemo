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

- (CGFloat)heightInTableView:(UITableView *)tableView;

- (void)updateStandardImageType:(SRRoomModelStandardImageType)imageType;

@end
