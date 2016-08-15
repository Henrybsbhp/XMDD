//
//  ShopListActionCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopListActionCell.h"
#import "CKLine.h"

@interface ShopListActionCell ()
@property (nonatomic, strong) CKLine *vecticalLine;
@end

@implementation ShopListActionCell

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

    _navigationButton = [self addButtonWithTitle:@"导航" imageName:@"icon_navigation_3_0"];
    _phoneButton = [self addButtonWithTitle:@"电话" imageName:@"icon_phone_3_0"];
    
    _vecticalLine = [[CKLine alloc] initWithFrame:CGRectZero];
    _vecticalLine.lineAlignment = CKLineAlignmentVerticalRight;
    [self.contentView addSubview:_vecticalLine];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_navigationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
    }];
    
    [_phoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.navigationButton.mas_right);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.right.equalTo(self.contentView).offset(-14);
        make.width.equalTo(self.navigationButton.mas_width);
    }];
    
    [_vecticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.mas_equalTo(1);
        make.top.equalTo(self.contentView).offset(6);
        make.bottom.equalTo(self.contentView).offset(-6);
        make.left.equalTo(self.navigationButton.mas_right);
    }];
    
}

- (UIButton *)addButtonWithTitle:(NSString *)title imageName:(NSString *)imgname {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectZero];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:kDarkTextColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setImage:[UIImage imageNamed:imgname] forState:UIControlStateNormal];
    [self.contentView addSubview:button];
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, 9, 0, 0)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -9, 0, 0)];
    return button;
}

@end
