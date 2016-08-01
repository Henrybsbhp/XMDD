//
//  KeyboardHelper.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "KeyboardHelper.h"

@interface KeyboardHelper ()
@property (nonatomic, assign) CGFloat mLastKBSizeH;
@end
@implementation KeyboardHelper

- (instancetype)init {
    self = [super init];
    [self addKeyboardNotification];
    return self;
}

- (void)dealloc {
    [self removeKeyboardNotification];
}

#pragma mark - keyboard
- (void)addKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    CGRect keyboardBounds;
    [(notif.userInfo)[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    
    NSTimeInterval animationDuration;
    [(notif.userInfo)[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    UIViewAnimationCurve curve = [[notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    NSInteger kbSizeH = keyboardBounds.size.height;
    
    if ([self.delegate respondsToSelector:@selector(keyboardChangeWithHeight:duration:curve:forHiden:)])
    {
        [self.delegate keyboardChangeWithHeight:kbSizeH
                                       duration:animationDuration
                                          curve:(UIViewAnimationOptions)(curve << 16)
                                       forHiden:NO];
    }
    
    self.mLastKBSizeH = kbSizeH;
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    if (self.mLastKBSizeH == 0)
    {
        return;
    }
    
    CGRect keyboardBounds;
    [(notif.userInfo)[UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    
    NSTimeInterval animationDuration;
    [(notif.userInfo)[UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    
    UIViewAnimationCurve curve = [[notif.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    NSInteger kbSizeH = keyboardBounds.size.height;
    
    if ([self.delegate respondsToSelector:@selector(keyboardChangeWithHeight:duration:curve:forHiden:)])
    {
        [self.delegate keyboardChangeWithHeight:kbSizeH
                                       duration:animationDuration
                                          curve:(UIViewAnimationOptions)(curve << 16)
                                       forHiden:YES];
    }
    
    self.mLastKBSizeH = 0;
}


@end
