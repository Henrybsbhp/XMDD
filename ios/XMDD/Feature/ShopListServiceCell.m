//
//  ShopListServiceCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopListServiceCell.h"

@implementation ShopListServiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    _serviceLabelTapGesture = [[UITapGestureRecognizer alloc] init];
    _priceLabelTapGesture = [[UITapGestureRecognizer alloc] init];
    
    _serviceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _serviceLabel.font = [UIFont systemFontOfSize:14];
    _serviceLabel.textColor = kDarkTextColor;
    [_serviceLabel addGestureRecognizer:_serviceLabelTapGesture];
    [self.contentView addSubview:_serviceLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel.font = [UIFont systemFontOfSize:16];
    _priceLabel.textColor = kOrangeColor;
    _priceLabel.textAlignment = NSTextAlignmentRight;
    [_priceLabel addGestureRecognizer:_priceLabelTapGesture];
    [self.contentView addSubview:_priceLabel];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).offset(14);
    }];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.serviceLabel.mas_right).offset(8);
        make.right.equalTo(self.contentView).offset(-14);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
}

@end
