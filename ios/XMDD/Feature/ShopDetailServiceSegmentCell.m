//
//  ShopDetailServiceSegmentCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailServiceSegmentCell.h"
#import <CoreGraphics/CoreGraphics.h>

@implementation ShopDetailServiceSegmentCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupSegmentControlWithItems:(NSArray *)items {
    if (_segmentControl || !items) {
        return;
    }
    
    _segmentControl = [[UISegmentedControl alloc] initWithItems:items];
    _segmentControl.tintColor = kDefTintColor;
    [self.contentView addSubview:_segmentControl];
    
    @weakify(self);
    [_segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(16);
        make.right.equalTo(self.contentView).offset(-16);
        make.height.mas_equalTo(29);
        make.centerY.equalTo(self.contentView);
    }];
}

@end
