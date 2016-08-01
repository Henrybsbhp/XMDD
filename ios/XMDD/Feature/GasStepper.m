//
//  GasStepper.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/4/6.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasStepper.h"
#import "CKLine.h"

@implementation GasStepper

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.borderWidth = 1;
    self.borderColor = kOrangeColor;
    
    UIButton *leftB = [[UIButton alloc] initWithFrame:CGRectZero];
    [leftB setImage:[UIImage imageNamed:@"gas_minus_red"] forState:UIControlStateNormal];
    self.leftButton = leftB;
    [self addSubview:leftB];
    
    UIButton *rightB = [[UIButton alloc] initWithFrame:CGRectZero];
    [rightB setImage:[UIImage imageNamed:@"gas_add_red"] forState:UIControlStateNormal];
    self.rightButton = rightB;
    [self addSubview:rightB];

    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectZero];
    titleL.textColor = kOrangeColor;
    titleL.font = [UIFont boldSystemFontOfSize:15];
    titleL.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = titleL;
    [self addSubview:titleL];
    
    CKLine *HLine1 = [[CKLine alloc] initWithFrame:CGRectZero];
    HLine1.lineColor = kOrangeColor;
    HLine1.lineOptions = CKLineOptionNone;
    HLine1.lineAlignment = CKLineAlignmentVerticalLeft;
    HLine1.linePointWidth = 1;
    [self addSubview:HLine1];
    
    CKLine *HLine2 = [[CKLine alloc] initWithFrame:CGRectZero];
    HLine2.lineColor = kOrangeColor;
    HLine2.lineOptions = CKLineOptionNone;
    HLine2.lineAlignment = CKLineAlignmentVerticalLeft;
    HLine2.linePointWidth = 1;
    [self addSubview:HLine2];

    @weakify(self);
    [leftB mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.mas_equalTo(52);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
    }];
    
    [rightB mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.width.mas_equalTo(52);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
    }];
    
    [HLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.left.equalTo(leftB.mas_right);
    }];
    
    [HLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(rightB.mas_left);
    }];
    
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftB.mas_right);
        make.right.equalTo(rightB.mas_left);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

@end
