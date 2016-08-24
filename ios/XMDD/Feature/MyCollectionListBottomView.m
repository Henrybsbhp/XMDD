//
//  MyCollectionListBottomView.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyCollectionListBottomView.h"
#import "CKLine.h"

@interface MyCollectionListBottomView ()
@property (nonatomic, strong) CKLine *topLine;
@end
@implementation MyCollectionListBottomView

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
    
    _checkBox = [[UIButton alloc] initWithFrame:CGRectZero];
    [_checkBox setImage:[UIImage imageNamed:@"checkbox_normal_301"] forState:UIControlStateNormal];
    [_checkBox setImage:[UIImage imageNamed:@"checkbox_selected"] forState:UIControlStateSelected];
    _checkBox.titleLabel.font = [UIFont systemFontOfSize:14];
    [_checkBox setTitleColor:kDefTintColor forState:UIControlStateNormal];
    [_checkBox setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
    [_checkBox setTitle:@"全选" forState:UIControlStateNormal];
    [self addSubview:_checkBox];
    
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
    UIImage *bgimg = [[UIImage imageNamed:@"btn_bg_red"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [_deleteButton setBackgroundImage:bgimg forState:UIControlStateNormal];
    [self addSubview:_deleteButton];

    _topLine = [[CKLine alloc] initWithFrame:CGRectZero];
    _topLine.lineAlignment = CKLineAlignmentHorizontalTop;
    [self addSubview:_topLine];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    @weakify(self);
    [_checkBox mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(80, 40));
        make.centerY.equalTo(self);
        make.left.equalTo(self);
    }];
    
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.size.mas_equalTo(CGSizeMake(72, 37));
        make.right.equalTo(self).offset(-12);
        make.centerY.equalTo(self);
    }];
    
    [_topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(1);
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
}

@end
