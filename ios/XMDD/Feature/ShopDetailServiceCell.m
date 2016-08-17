//
//  ShopDetailServiceCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailServiceCell.h"
#import "NSString+RectSize.h"

#define kPriceLabelMaxWidth     150

@implementation ShopDetailServiceCell

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

    _radioButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [_radioButton setImage:[UIImage imageNamed:@"cm_radio1"] forState:UIControlStateNormal];
    [_radioButton setImage:[UIImage imageNamed:@"cm_radio2"] forState:UIControlStateSelected];
    [self.contentView addSubview:_radioButton];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont systemFontOfSize:14];
    _titleLabel.textColor = kDarkTextColor;
    _titleLabel.numberOfLines = 0;
    [self.contentView addSubview:_titleLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel.font = [UIFont systemFontOfSize:14];
    _priceLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_priceLabel];
    
    _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _descLabel.font = [UIFont systemFontOfSize:14];
    _descLabel.textColor = kGrayTextColor;
    _descLabel.numberOfLines = 0;
    [self.contentView addSubview:_descLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_radioButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.left.equalTo(self.contentView).offset(floor(9));
        make.top.equalTo(self.contentView);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.contentView).offset(6);
        make.left.equalTo(self.radioButton.mas_right).offset(4);
    }];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.contentView).offset(4);
        make.right.equalTo(self.contentView).offset(-14);
        make.width.mas_equalTo(kPriceLabelMaxWidth);
        make.left.equalTo(self.titleLabel.mas_right);
    }];
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.radioButton.mas_right).offset(4);
        make.right.equalTo(self.contentView).offset(-14);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
    }];
}

+ (CGFloat)cellHeightWithTitle:(NSString *)title desc:(NSString *)desc boundWidth:(CGFloat)width {
    CGSize titleSize = [title labelSizeWithWidth:width-kPriceLabelMaxWidth font:[UIFont systemFontOfSize:14]];
    CGFloat height = titleSize.height + 6 + 15;
    if (desc.length > 0) {
        height += 8 + [desc labelSizeWithWidth:width-9-30-4-14 font:[UIFont systemFontOfSize:14]].height;
    }
    return ceil(MAX(height, 30));
}

@end
