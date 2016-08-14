//
//  ShopDetailServiceSwitchCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailServiceSwitchCell.h"

@interface ShopDetailServiceSwitchCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowView;
@end

@implementation ShopDetailServiceSwitchCell

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
    _titleLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:_titleLabel];
    
    _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _arrowView.image = [UIImage imageNamed:@"cw_arrow_down"];
    _arrowView.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:_arrowView];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.contentView).offset(4);
        make.left.greaterThanOrEqualTo(self.contentView).offset(14);
        make.centerX.equalTo(self.contentView);
    }];
    
    [_arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.titleLabel.mas_centerY);
        make.left.equalTo(self.titleLabel.mas_right).offset(5);
        make.right.lessThanOrEqualTo(self.contentView).offset(-14);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
}

- (void)setExpand:(BOOL)expand title:(NSString *)title animated:(BOOL)animated {
    _isExpanded = expand;
    _titleLabel.text = title;
    if (!animated) {
        _arrowView.transform = CGAffineTransformMakeRotation(expand ? M_PI : 0);
    }
    else {
        [UIView animateWithDuration:0.35 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _arrowView.transform = CGAffineTransformMakeRotation(expand ? M_PI : 0);
        } completion:^(BOOL finished) {
            
        }];
    }
}

@end
