//
//  GasTabView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasTabView.h"
#import "CKLine.h"

@interface GasTabView ()
@property (nonatomic, strong) UIButton *leftTab;
@property (nonatomic, strong) UIButton *rightTab;
@property (nonatomic, strong) CKLine *bottomLine;
@property (nonatomic, strong) CKSegmentHelper *segHelper;
@end

@implementation GasTabView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.bottomLine = [[CKLine alloc] initWithFrame:CGRectZero];
    self.bottomLine.lineColor = HEXCOLOR(@"#15AC1F");
    self.bottomLine.lineAlignment = CKLineAlignmentHorizontalBottom;
    self.bottomLine.linePointWidth = 0.5;
    [self addSubview:self.bottomLine];

    UIImage *tabbg1 = [[UIImage imageNamed:@"gas_tab_bg1"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
    UIImage *tabbg2 = [[UIImage imageNamed:@"gas_tab_bg2"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 13)];
    
    self.leftTab = [[UIButton alloc] initWithFrame:CGRectZero];
    self.leftTab.backgroundColor = [UIColor clearColor];
    [self.leftTab setBackgroundImage:tabbg1 forState:UIControlStateNormal];
    [self.leftTab setBackgroundImage:tabbg1 forState:UIControlStateHighlighted];
    [self.leftTab setBackgroundImage:tabbg2 forState:UIControlStateSelected];
    [self.leftTab setTitleColor:HEXCOLOR(@"#15AC1F") forState:UIControlStateSelected];
    [self.leftTab setTitleColor:HEXCOLOR(@"#888888") forState:UIControlStateNormal];
    self.leftTab.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.leftTab setTitle:@"普通充值" forState:UIControlStateNormal];
    [self.leftTab addTarget:self action:@selector(actionTabClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.leftTab];
    
    self.rightTab = [[UIButton alloc] initWithFrame:CGRectZero];
    self.rightTab.backgroundColor = [UIColor clearColor];
    [self.rightTab setBackgroundImage:tabbg1 forState:UIControlStateNormal];
    [self.rightTab setBackgroundImage:tabbg1 forState:UIControlStateHighlighted];
    [self.rightTab setBackgroundImage:tabbg2 forState:UIControlStateSelected];
    [self.rightTab setTitleColor:HEXCOLOR(@"#15AC1F") forState:UIControlStateSelected];
    [self.rightTab setTitleColor:HEXCOLOR(@"#888888") forState:UIControlStateNormal];
    self.rightTab.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.rightTab setTitle:@"浙商卡充值" forState:UIControlStateNormal];
    [self.rightTab addTarget:self action:@selector(actionTabClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.rightTab];
    
    UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gas_hui"]];
    [self.rightTab addSubview:imgV];
    
    @weakify(self);
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];

    CGFloat tabw = floor((self.frame.size.width/2.0-2));
    [self.leftTab mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self);
        make.left.equalTo(self).offset(5);
        make.width.mas_equalTo(tabw);
        make.height.mas_equalTo(34);
    }];
    
    [self.rightTab mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self).offset(-5);
        make.width.mas_equalTo(tabw);
        make.height.mas_equalTo(34);
    }];
    
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(15, 14));
        make.centerX.equalTo(self.rightTab.mas_right).offset(-11);
        make.centerY.equalTo(self.rightTab.mas_top).offset(6);
    }];
    
    [self setupSegmentHelper];
}

- (void)setupSegmentHelper
{
    self.segHelper = [[CKSegmentHelper alloc] init];
    @weakify(self);
    [self.segHelper addItems:@[self.leftTab,self.rightTab] forGroupName:@"Tab" withChangedBlock:^(UIButton *item, BOOL selected) {
        @strongify(self);
        item.selected = selected;
        item.userInteractionEnabled = !selected;
        if (selected) {
            [self bringSubviewToFront:item];
            [self insertSubview:self.bottomLine belowSubview:item];
        }
    }];
    [self.segHelper selectItem:self.leftTab];
}

- (void)actionTabClick:(id)sender
{
    [self.segHelper selectItem:sender forGroupName:@"Tab"];
    if (self.tabBlock) {
        self.tabBlock([self.leftTab isEqual:sender] ? 0 : 1);
    }
}

@end
