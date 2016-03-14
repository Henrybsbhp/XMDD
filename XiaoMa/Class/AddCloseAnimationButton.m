//
//  AddCloseAnimationButton.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "AddCloseAnimationButton.h"

@implementation AddCloseAnimationButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

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
    _closing = NO;
    UIImage *addImg = [UIImage imageNamed:@"mins_add"];
    [self setImage:addImg forState:UIControlStateNormal];
    [self setImage:addImg forState:UIControlStateHighlighted];
}

- (void)setClosing:(BOOL)closing WithAnimation:(BOOL)animate
{
    _closing = closing;
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(closing ? M_PI_2/2 : 0);
    if (animate) {
        [UIView animateWithDuration:0.24 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.transform = transform;
        } completion:^(BOOL finished) {
            
        }];
    }
    else {
        self.transform = transform;
    }
}

@end
