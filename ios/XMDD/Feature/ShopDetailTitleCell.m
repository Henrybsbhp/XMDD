//
//  ShopDetailTitleCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailTitleCell.h"

@implementation ShopDetailTitleCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.backgroundColor = [UIColor whiteColor];
    
    _titleLabel = [self createBaseLabelWithFont:[UIFont systemFontOfSize:17] color:kBlackTextColor];
    [self.contentView addSubview:_titleLabel];
    
    _tipLabel = [self createBaseLabelWithFont:[UIFont systemFontOfSize:11] color:[UIColor whiteColor]];
    _tipLabel.layer.cornerRadius = 3;
    _tipLabel.layer.masksToBounds = YES;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_tipLabel];
    [self setIsTipHighlight:NO];

    _timeLabel = [self createBaseLabelWithFont:[UIFont systemFontOfSize:12] color:kGrayTextColor];
    [self.contentView addSubview:_timeLabel];
    
    _distanceLabel = [self createBaseLabelWithFont:[UIFont systemFontOfSize:12] color:kGrayTextColor];
    _distanceLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_distanceLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView).offset(10);
        make.right.equalTo(self.contentView).offset(-14);
    }];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(46, 17));
        make.top.equalTo(_titleLabel.mas_bottom).offset(6);
        make.left.equalTo(self.contentView).offset(15);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_tipLabel.mas_right).offset(5);
        make.centerY.equalTo(_tipLabel.mas_centerY);
    }];
    
    [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_tipLabel.mas_centerY);
        make.right.equalTo(self.contentView).offset(-14);
    }];
}

#pragma mark - Setter
- (void)setIsTipHighlight:(BOOL)isTipHighlight {
    _isTipHighlight = isTipHighlight;
    _tipLabel.backgroundColor = isTipHighlight ? kDefTintColor : HEXCOLOR(@"#cfdbd3");
}

#pragma mark - Util
- (UILabel *)createBaseLabelWithFont:(UIFont *)font color:(UIColor *)color {
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    lable.textAlignment = NSTextAlignmentLeft;
    lable.font = font;
    lable.textColor = color;
    return lable;
}

@end
