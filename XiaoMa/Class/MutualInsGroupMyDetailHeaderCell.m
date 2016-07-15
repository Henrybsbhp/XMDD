//
//  MutualInsGroupMyDetailHeaderCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupMyDetailHeaderCell.h"

@interface MutualInsGroupMyDetailHeaderCell ()
@property (nonatomic, strong) UIView *logoContainerView;
@end

@implementation MutualInsGroupMyDetailHeaderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.logoContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.logoContainerView];
    
    self.logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.logoContainerView addSubview:self.logoView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.textColor = kDarkTextColor;
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.logoContainerView addSubview:self.titleLabel];
    
    self.tipButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.tipButton.userInteractionEnabled = NO;
    self.tipButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.tipButton setTitleColor:HEXCOLOR(@"#fd5d20") forState:UIControlStateNormal];
    UIImage *tipBgImg = [[UIImage imageNamed:@"mins_tip_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 0)];
    [self.tipButton setBackgroundImage:tipBgImg forState:UIControlStateNormal];
    self.tipButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 15);
    [self.contentView addSubview:self.tipButton];

    [self makeDefaultConstraints];
}


- (void)makeDefaultConstraints {
    @weakify(self);
    [self.logoContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.centerY.equalTo(self.contentView.mas_top).offset(33);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.logoContainerView);
        make.top.equalTo(self.logoContainerView);
        make.bottom.equalTo(self.logoContainerView);
        make.size.mas_equalTo(CGSizeMake(29, 29));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.left.equalTo(self.logoView.mas_right).offset(7);
        make.right.equalTo(self.logoContainerView);
        make.top.equalTo(self.logoContainerView);
        make.bottom.equalTo(self.logoContainerView);
    }];
    
    [self.tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        
        @strongify(self);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(9);
    }];
}

@end
