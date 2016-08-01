//
//  MutualInsGroupMySimpleHeaderCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupMySimpleHeaderCell.h"
#import "NSString+RectSize.h"

#define kHorMargin     16

@implementation MutualInsGroupMySimpleHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.logoView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = kDarkTextColor;
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    [self.contentView addSubview:self.titleLabel];
    
    self.tipButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.tipButton.userInteractionEnabled = NO;
    self.tipButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.tipButton setTitleColor:HEXCOLOR(@"#fd5d20") forState:UIControlStateNormal];
    UIImage *tipBgImg = [[UIImage imageNamed:@"mins_tip_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    [self.tipButton setBackgroundImage:tipBgImg forState:UIControlStateNormal];
    self.tipButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 15);
    [self.contentView addSubview:self.tipButton];
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.textColor = kGrayTextColor;
    self.descLabel.font = [UIFont systemFontOfSize:13];
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    self.descLabel.numberOfLines = 0;
    [self.contentView addSubview:self.descLabel];
    
    [self makeDefaultConstraints];
}

- (void)makeDefaultConstraints {
    @weakify(self);
    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.top.equalTo(self.contentView).offset(21);
        make.size.mas_equalTo(CGSizeMake(42, 42));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.logoView.mas_right).offset(10);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.centerY.equalTo(self.logoView.mas_centerY);
    }];
    
    [self.tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(9);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.contentView).offset(kHorMargin);
        make.right.equalTo(self.contentView).offset(-kHorMargin);
        make.top.equalTo(self.logoView.mas_bottom).offset(12);
    }];
}

+ (CGFloat)heightWithDesc:(NSString *)desc isTail:(BOOL)isTail {
    CGFloat descHeight = ceil([desc labelSizeWithWidth:ScreenWidth - 2*kHorMargin font:[UIFont systemFontOfSize:13]].height);
    return 21 + 42 + 12 + descHeight + (isTail ? 19 : 12);
}

@end
