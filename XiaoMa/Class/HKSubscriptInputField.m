//
//  HKSubscriptTextField.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "HKSubscriptInputField.h"
#import "CKLine.h"
#import <Masonry.h>

@interface HKSubscriptInputField ()
@property (nonatomic, strong) UIImageView *subscriptView;
@end

@implementation HKSubscriptInputField

- (id)initWithFrame:(CGRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *) inCoder {
    self = [super initWithCoder:inCoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _subscriptImageName = @"ins_arrow_pen";
    
    CKLine *line = [[CKLine alloc] initWithFrame:CGRectZero];
    line.lineAlignment = CKLineAlignmentHorizontalBottom;
    [self addSubview:line];
    
    _inputField = [[CKLimitTextField alloc] initWithFrame:CGRectZero];
    _inputField.font = [UIFont systemFontOfSize:16];
    _inputField.backgroundColor = [UIColor clearColor];
    _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addSubview:_inputField];
    
    _subscriptView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_subscriptImageName]];
    [_subscriptView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_subscriptView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    [self addGestureRecognizer:tap];
    
    @weakify(self);
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];
    
    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(24);
        make.left.equalTo(self).offset(10);
        make.bottom.equalTo(self);
    }];
    
    [self.subscriptView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        make.left.equalTo(self.inputField.mas_right);
    }];
    
}

- (void)setSubscriptImageName:(NSString *)subscriptImageName
{
    self.subscriptView.image = [UIImage imageNamed:subscriptImageName];
}

- (void)actionTap:(UITapGestureRecognizer *)tap
{
    if (self.inputField.userInteractionEnabled && self.inputField.enabled) {
        [self.inputField becomeFirstResponder];
    }
}

@end
