//
//  ShopDetailCommentLoadingCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailCommentLoadingCell.h"

@implementation ShopDetailCommentLoadingCell
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
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_activityView setHidesWhenStopped:YES];
    [self.contentView addSubview:_activityView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textColor = kDarkTextColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(_titleLabel.mas_left).offset(-10);
        make.centerY.equalTo(self.contentView);
        make.left.greaterThanOrEqualTo(self.contentView).offset(14);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.center.equalTo(self.contentView);
        make.right.lessThanOrEqualTo(self.contentView).offset(-14);
    }];
}

@end
