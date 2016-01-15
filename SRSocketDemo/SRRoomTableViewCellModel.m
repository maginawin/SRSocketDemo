//
//  SRRoomTableViewCellModel.m
//  Limente
//
//  Created by wangwendong on 15/12/28.
//  Copyright © 2015年 sunricher. All rights reserved.
//

#import "SRRoomTableViewCellModel.h"

@implementation SRRoomTableViewCellModel

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupDidInit];
    }
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    SRRoomTableViewCellModel *model = [[SRRoomTableViewCellModel allocWithZone:zone] init];
    model.name = self.name.copy;
    model.image = self.image.copy;
    model.isHighlighted = self.isHighlighted;
    model.index = self.index;
    model.lamps = self.lamps.mutableCopy;
    
    return model;
}

- (void)setupDidInit {
    _name = @"Room";
//    _image = [UIImage imageNamed:@"kitchen"];
    [self updateStandardImageType:SRRoomModelStandardImageTypeLivingRoom];
    _isHighlighted = NO;
    _index = 0;
    _lamps = [NSMutableArray array];
}

- (CGFloat)heightInTableView:(UITableView *)tableView {
    if (!tableView) {
        return 38.f;
    }
    
    return (CGRectGetWidth(tableView.bounds) - 16) * SRRoomTableViewCellHeightDivWidth + 38.f;
}

- (void)updateStandardImageType:(SRRoomModelStandardImageType)imageType {
    switch (imageType) {
        case SRRoomModelStandardImageTypeLivingRoom: {
            _image = [UIImage imageNamed:@"living_room"];
            
            break;
        }
        case SRRoomModelStandardImageTypeKitchen: {
            _image = [UIImage imageNamed:@"kitchen"];
        
            break;
        }
    }
}

@end
