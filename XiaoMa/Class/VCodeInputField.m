//
//  PwdInputField.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "VCodeInputField.h"

@interface VCodeInputField ()

@end

@implementation VCodeInputField
- (void)awakeFromNib
{
    self.rightButton = [self _rightBtn];
    self.rightView = self.rightButton;
    self.rightViewMode = UITextFieldViewModeNever;
}

- (void)showRightViewAfterInterval:(NSTimeInterval)interval
{
    CKAfter(interval, ^{
        self.rightViewMode = UITextFieldViewModeAlways;
    });
}

- (void)showRightViewAfterInterval:(NSTimeInterval)interval withFilter:(BOOL(^)(void))filter
{
    CKAfter(interval, ^{
        if (filter && filter()) {
            self.rightViewMode = UITextFieldViewModeAlways;
        }
    });
}

- (void)hideRightView
{
    self.rightViewMode = UITextFieldViewModeNever;
}

- (UIButton *)_rightBtn
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    [btn setTitle:@"验证码收不到?" forState:UIControlStateNormal];
    btn.titleLabel.textAlignment = NSTextAlignmentRight;
    [btn setTitleColor:kDefTintColor forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    return btn;
}


@end
