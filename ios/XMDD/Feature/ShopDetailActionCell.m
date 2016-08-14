//
//  ShopDetailActionCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailActionCell.h"

@implementation ShopDetailActionCell

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
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.numberOfLines = 2;
    _titleLabel.textColor = kDarkTextColor;
    [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_titleLabel];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_imageView];
    
    CKLine *line = [[CKLine alloc] initWithFrame:CGRectZero];
    line.lineOptions = CKLineOptionNone;
    line.lineAlignment = CKLineAlignmentVerticalRight;
    [self.contentView addSubview:line];

    @weakify(self);
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.imageView.mas_left).offset(-4);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.mas_equalTo(65);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.mas_equalTo(1);
        make.right.equalTo(self.imageView.mas_left);
        make.top.equalTo(self.contentView).offset(9);
        make.bottom.equalTo(self.contentView).offset(-9);
    }];
}

@end
