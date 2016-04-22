//
//  MutualInsGrouponMsgCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponMsgCell.h"
#import "MutualInsConstants.h"
#import "NSString+RectSize.h"
#import <Masonry.h>

#define kCellMargin      3
#define kLogoViewLength     45

@interface MutualInsGrouponMsgCell ()
@property (nonatomic, strong) UIView *msgContainerView;
@property (nonatomic, strong) UIImageView *msgBgView;
@property (nonatomic, strong) UILabel *msgLabel;
@property (nonatomic, strong) UIView *timeContainerView;
@property (nonatomic, strong) UIImageView *timeContainerBgView;
@end
@implementation MutualInsGrouponMsgCell

- (void)awakeFromNib {
    // Initialization code
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.timeContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.timeContainerView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.timeContainerView];

    self.timeContainerBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.timeContainerBgView.image = [[UIImage imageNamed:@"mins_bg_gary"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [self.timeContainerView addSubview:self.timeContainerBgView];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    [self.timeContainerView addSubview:self.timeLabel];
    
    self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.logoView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.logoView];
    
    self.logoViewTapGesture = [[UITapGestureRecognizer alloc] init];
    [self.logoView addGestureRecognizer:self.logoViewTapGesture];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = kGrayTextColor;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.titleLabel];
    
    self.msgContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    self.msgContainerView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.msgContainerView];
    
    self.msgBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.msgContainerView addSubview:self.msgBgView];
    
    self.msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.msgLabel.backgroundColor = [UIColor clearColor];
    self.msgLabel.font = [UIFont systemFontOfSize:14];
    self.msgLabel.numberOfLines = 0;
    self.msgLabel.textColor = kDarkTextColor;
    [self.msgContainerView addSubview:self.msgLabel];
    
    self.atRightSide = NO;
}

- (void)setAtRightSide:(BOOL)atRightSide
{
    _atRightSide = atRightSide;
    NSString *strimg = atRightSide ? @"mins_bubble_right" : @"mins_bubble_left";
    self.msgBgView.image = [[UIImage imageNamed:strimg] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 8, 5, 8)];
    self.titleLabel.textAlignment = atRightSide ? NSTextAlignmentRight : NSTextAlignmentLeft;
    self.msgLabel.textColor = atRightSide ? [UIColor whiteColor] : kDarkTextColor;
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    self.msgLabel.text = message;
}

- (void)updateConstraints
{
    @weakify(self);
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.timeContainerView).insets(UIEdgeInsetsMake(0, 5, 0, 5));
    }];
    
    [self.timeContainerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.timeContainerView);
    }];
    
    [self.timeContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(16);
        make.centerY.equalTo(self.contentView.mas_top).offset(20);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.logoView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.top.equalTo(self.contentView).offset(35);
        if (self.atRightSide) {
            make.right.equalTo(self.contentView).offset(-kCellMargin);
        }
        else {
            make.left.equalTo(self.contentView).offset(kCellMargin);
        }
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.logoView.mas_top);
        make.height.mas_equalTo(16);
        if (self.atRightSide) {
            make.left.equalTo(self.contentView).offset(kCellMargin);
            make.right.equalTo(self.logoView.mas_left).offset(-8);
        }
        else {
            make.left.equalTo(self.logoView.mas_right).offset(8);
            make.right.equalTo(self.contentView).offset(-kCellMargin);
        }
    }];
    [self.msgContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(3);
        if (self.atRightSide) {
            make.left.greaterThanOrEqualTo(self.contentView).offset(70);
            make.right.equalTo(self.logoView.mas_left).offset(-5);
        }
        else {
            make.left.equalTo(self.logoView.mas_right).offset(5);
            make.right.lessThanOrEqualTo(self.contentView).offset(-70);
        }
    }];
    
    [self.msgBgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.msgContainerView);
    }];
 
    [self.msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.msgContainerView).offset(8);
        make.bottom.equalTo(self.msgContainerView).offset(-8);
        if (self.atRightSide) {
            make.left.equalTo(self.msgContainerView).offset(10);
            make.right.equalTo(self.msgContainerView).offset(-15);
        }
        else {
            make.left.equalTo(self.msgContainerView).offset(15);
            make.right.equalTo(self.msgContainerView).offset(-10);
        }
    }];
    [super updateConstraints];
}

+ (CGFloat)heightWithBoundsWidth:(CGFloat)width message:(NSString *)msg
{
    width = width - 45 - kCellMargin - 5 - 70 - 10 - 15;
    CGSize size = [msg labelSizeWithWidth:width font:[UIFont systemFontOfSize:14]];
    return MAX(35+45+15, ceil(size.height+35+16+3+8+8+15));
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
