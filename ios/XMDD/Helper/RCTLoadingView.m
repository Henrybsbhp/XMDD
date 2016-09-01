//
//  RCTLoadingView.m
//  XMDD
//
//  Created by jiangjunchen on 16/9/1.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "RCTLoadingView.h"

@implementation RCTLoadingView

- (void)setAnimate:(BOOL)animate {
    if (_animate != animate) {
        _animate = animate;
        if (animate) {
            [self startActivityAnimationWithType:self.animationType];
        }
        else {
            [self stopActivityAnimation];
        }
    }
}

- (void)setAnimationType:(ActivityIndicatorType)animationType {
    if (_animationType != animationType) {
        _animationType = animationType;
        if (self.animate) {
            [self startActivityAnimationWithType:animationType];
        }
    }
}

@end
