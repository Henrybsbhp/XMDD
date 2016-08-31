//
//  HKLoadingView.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKLoadingView.h"
#import "UIView+JTLoadingView.h"

@implementation HKLoadingView

- (void)startMONAnimating {
    [self startActivityAnimationWithType:MONActivityIndicatorType];
}

- (void)startGifAnimating {
    [self startActivityAnimationWithType:GifActivityIndicatorType];
}

- (void)startTYMAnimating {
    [self startActivityAnimationWithType:TYMActivityIndicatorType];
}

- (void)startUIAnimating {
    [self startActivityAnimationWithType:UIActivityIndicatorType];
}

- (void)stopAnimating {
    [self stopActivityAnimation];
}

- (BOOL)isAnimating {
    return self.isActivityAnimating;
}

@end
