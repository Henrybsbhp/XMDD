//
//  ShopDetailCommentTitleCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailCommentTitleCell.h"

@implementation ShopDetailCommentTitleCell

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
    
    _ratingView = [[JTRatingView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    _ratingView.userInteractionEnabled = NO;
    [self.contentView addSubview:_ratingView];
    
    _rateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _rateLabel.font = [UIFont systemFontOfSize:12];
    _rateLabel.textColor = kYelloColor;
    [self.contentView addSubview:_rateLabel];
    
    _commentButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [_commentButton setTitleColor:kDefTintColor forState:UIControlStateNormal];
    _commentButton.userInteractionEnabled = NO;
    [self.contentView addSubview:_commentButton];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_ratingView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(14);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(80, 20));
    }];
    
    [_rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.ratingView.mas_right).offset(0);
        make.centerY.equalTo(self.contentView);
    }];
    
    [_commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.contentView).offset(-14);
        make.centerY.equalTo(self.contentView);
    }];
}

@end
