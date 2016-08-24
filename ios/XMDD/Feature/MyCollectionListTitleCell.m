//
//  MyCollectionListTitleCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyCollectionListTitleCell.h"

@implementation MyCollectionListTitleCell

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
    
    _logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_logoView];
    
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont systemFontOfSize:15];
    _titleLabel.textColor = kBlackTextColor;
    [self.contentView addSubview:_titleLabel];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipLabel.layer.cornerRadius = 3;
    _tipLabel.layer.masksToBounds = YES;
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    _tipLabel.font = [UIFont systemFontOfSize:12];
    _tipLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_tipLabel];
    
    _addressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _addressLabel.font = [UIFont systemFontOfSize:13];
    _addressLabel.textColor = kGrayTextColor;
    [_addressLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_addressLabel];
    
    _distanceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _distanceLabel.font = [UIFont systemFontOfSize:13];
    _distanceLabel.textColor = kGrayTextColor;
    _distanceLabel.textAlignment = NSTextAlignmentRight;
    [_distanceLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_distanceLabel];

    _closedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"vacation_icon"]];
    _closedView.hidden = YES;
    [self.contentView addSubview:_closedView];
    
    _checkBox = [[UIButton alloc] initWithFrame:CGRectZero];
    _checkBox.hidden = YES;
    [_checkBox setImage:[UIImage imageNamed:@"collect_uncheck"] forState:UIControlStateNormal];
    [_checkBox setImage:[UIImage imageNamed:@"collect_check"] forState:UIControlStateSelected];
    _checkBox.imageEdgeInsets = UIEdgeInsetsMake(-20, 8, 0, 0);
    [self.contentView addSubview:_checkBox];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(73, 58));
        make.left.equalTo(self.contentView).offset(14);
        make.top.equalTo(self.contentView).offset(12);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.logoView.mas_top).offset(6);
        make.left.equalTo(self.logoView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-14);
    }];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.logoView.mas_right).offset(10);
        make.bottom.equalTo(self.logoView.mas_bottom).offset(-6);
    }];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.contentView).offset(-15);
        make.top.equalTo(self.contentView).offset(33);
        make.size.mas_equalTo(CGSizeMake(42, 17));
    }];
    
    [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.addressLabel.mas_bottom).offset(2);
        make.left.equalTo(self.addressLabel.mas_right).offset(8);
    }];
    
    [_closedView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(50, 40));
        make.top.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-14);
    }];
    
    [_checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.top.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
    }];
}


@end
