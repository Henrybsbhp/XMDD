//
//  HKNavigationBar.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKNavigationBar.h"

@interface HKNavigationBar ()
@property (nonatomic, strong) UIImageView *bottomShadowView;
@end
@implementation HKNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.backgroundColor = [UIColor clearColor];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    _bottomShadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cm_nav_shadow"]];
    [self addSubview:_bottomShadowView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont boldSystemFontOfSize:17];
    _titleLabel.textColor = kBlackTextColor;
    [_contentView addSubview:_titleLabel];

    _backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _backButton.tintColor = kDefTintColor;
    [_backButton setImage:[UIImage imageNamed:@"nav_back_300"] forState:UIControlStateNormal];
    [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, -18, 0, 0)];
    [_contentView addSubview:_backButton];

    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_bottomShadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(3);
    }];
    
    [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self.bottomShadowView.mas_top);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.contentView);
        make.centerY.equalTo(self.contentView).offset(10);
    }];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(20);
        make.left.equalTo(self.contentView).offset(6);
        make.size.mas_equalTo(CGSizeMake(50, 42));
    }];
}
@end
