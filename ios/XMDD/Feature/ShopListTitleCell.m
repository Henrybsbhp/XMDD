//
//  ShopListTitleCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopListTitleCell.h"

@interface ShopListTitleCell ()
@property (nonatomic, strong) UIImageView *commentImageView;
@end
@implementation ShopListTitleCell

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
    
    _ratingView = [[JTRatingView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    _ratingView.userInteractionEnabled = NO;
    [self.contentView addSubview:_ratingView];
    
    _rateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _rateLabel.textColor = kYelloColor;
    _rateLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_rateLabel];
    
    _commentImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rate_number"]];
    [self.contentView addSubview:_commentImageView];
    
    _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _commentLabel.textColor = kYelloColor;
    _commentLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:_commentLabel];

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
    [self.contentView addSubview:_closedView];
    
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
        make.top.equalTo(self.logoView.mas_top);
        make.left.equalTo(self.logoView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-14);
    }];
    
    [_ratingView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(80, 20));
        make.left.equalTo(self.logoView.mas_right).offset(10);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
    }];
    
    [_rateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.ratingView.mas_centerY);
        make.left.equalTo(self.ratingView.mas_right);
    }];
    
    [_commentImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.rateLabel.mas_right).offset(13);
        make.centerY.equalTo(self.ratingView.mas_centerY);
    }];
    
    [_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.commentImageView.mas_right).offset(5);
        make.centerY.equalTo(self.ratingView.mas_centerY);
    }];
    
    [_tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.contentView).offset(-16);
        make.top.equalTo(self.rateLabel.mas_top);
        make.size.mas_equalTo(CGSizeMake(42, 17));
    }];
    
    [_addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.logoView.mas_right).offset(10);
        make.bottom.equalTo(self.logoView.mas_bottom).offset(2);
    }];
    
    [_distanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.right.equalTo(self.contentView).offset(-14);
        make.bottom.equalTo(self.addressLabel.mas_bottom);
        make.left.equalTo(self.addressLabel.mas_right).offset(8);
    }];
    
    [_closedView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(50, 40));
        make.top.equalTo(self.contentView).offset(15);
        make.right.equalTo(self.contentView).offset(-14);
    }];
}

@end
