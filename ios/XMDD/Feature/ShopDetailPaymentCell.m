//
//  ShopDetailPaymentCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailPaymentCell.h"

@implementation ShopDetailPaymentCell

- (void)dealloc {
    
}

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
    
    _noteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _noteLabel.font = [UIFont systemFontOfSize:12];
    _noteLabel.textColor = kGrayTextColor;
    [self.contentView addSubview:_noteLabel];
    
    _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _priceLabel.font = [UIFont systemFontOfSize:16];
    _priceLabel.textColor = kOrangeColor;
    [self.contentView addSubview:_priceLabel];
    
    _payButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _payButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_payButton setTitle:@"支付" forState:UIControlStateNormal];
    [_payButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage *bgimg = [[UIImage imageNamed:@"btn_bg_orange"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [_payButton setBackgroundImage:bgimg forState:UIControlStateNormal];
    [self.contentView addSubview:_payButton];

    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_noteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView).offset(8);
        make.right.equalTo(self.contentView).offset(-14);
    }];
    
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(14);
        make.centerY.equalTo(self.payButton.mas_centerY);
        make.right.equalTo(self.payButton.mas_left).offset(10);
    }];
    
    [_payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(70, 30));
        make.right.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
}

+ (CGFloat)cellHeightWithNote:(NSString *)note {
    return note.length == 0 ? 50 : 70;
}

@end
