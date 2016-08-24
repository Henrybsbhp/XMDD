//
//  ShopCommentCell.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopCommentCell.h"
#import "NSString+RectSize.h"

#define kServicePrefixWidth 65

@implementation ShopCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    _logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_logoView];
    
    _ratingView = [[JTRatingView alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    _ratingView.userInteractionEnabled = NO;
    [self.contentView addSubview:_ratingView];
    
    _titleLabel = [self addLabelWithFontSize:13 andColor:kDarkTextColor];
    _timeLabel = [self addLabelWithFontSize:13 andColor:kGrayTextColor];
    _timeLabel.textAlignment = NSTextAlignmentRight;
    _servicePrefixLabel = [self addLabelWithFontSize:13 andColor:kDarkTextColor];
    _servicePrefixLabel.text = @"服务项目：";
    _serviceLabel = [self addLabelWithFontSize:13 andColor:kDarkTextColor];
    _serviceLabel.numberOfLines = 0;
    _serviceLabel.lineBreakMode = NSLineBreakByCharWrapping;
    _commentLabel = [self addLabelWithFontSize:13 andColor:kDarkTextColor];
    _commentLabel.numberOfLines = 0;
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(13);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.logoView.mas_right).offset(12);
        make.top.equalTo(self.contentView).offset(12);
        make.right.equalTo(self.contentView).offset(-14);
        make.height.mas_equalTo(16);
    }];
    
    [_ratingView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(80, 20));
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
        make.left.equalTo(self.logoView.mas_right).offset(12);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.ratingView.mas_centerY);
        make.right.equalTo(self.contentView).offset(-15);
    }];
    
    [_servicePrefixLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.logoView.mas_bottom).offset(5);
        make.left.equalTo(self.logoView.mas_right).offset(12);
        make.width.mas_equalTo(kServicePrefixWidth);
    }];
    
    [_serviceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.servicePrefixLabel.mas_top);
        make.left.equalTo(self.servicePrefixLabel.mas_right);
        make.right.equalTo(self.contentView).offset(-14);
    }];
    
    [_commentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.logoView.mas_right).offset(12);
        make.right.equalTo(self.contentView).offset(-14);
        make.top.equalTo(self.serviceLabel.mas_bottom).offset(6);
    }];
}

+ (CGFloat)cellHeightWithComment:(NSString *)comment serviceName:(NSString *)name andBoundsWidth:(CGFloat)width {
    CGFloat commentHeight = 0;
    NSString *serviceTitle = name ? name : @"服务项目：";
    CGFloat titleHeight = [serviceTitle labelSizeWithWidth:width-12-35-12-kServicePrefixWidth-14
                                                      font:[UIFont systemFontOfSize:13]].height;
    if (comment.length > 0) {
        commentHeight = [comment labelSizeWithWidth:width-12-35-12-14 font:[UIFont systemFontOfSize:13]].height;
        commentHeight += 6;
    }
    return ceil(13 + 35 + 5 + titleHeight + commentHeight + 15);
}

- (UILabel *)addLabelWithFontSize:(NSInteger)fontSize andColor:(UIColor *)color {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.font = [UIFont systemFontOfSize:fontSize];
    label.textColor = color;
    [self.contentView addSubview:label];
    
    return label;
}
@end
