//
//  UIView+JTLoadingView.h
//  XiaoNiuShared
//
//  Created by jiangjunchen on 14-7-5.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYMActivityIndicatorView.h"
#import "MONActivityIndicatorView.h"

typedef enum : NSUInteger {
    TYMActivityIndicatorType,
    MONActivityIndicatorType,
    UIActivityIndicatorType
} ActivityIndicatorType;

@interface UIView (JTLoadingView)<MONActivityIndicatorViewDelegate>

///(default is hidden)
@property (nonatomic, strong, readonly) UIView *activityIndicatorView;
///(defualt is hidden)
@property (nonatomic, strong, readonly) UIButton *indicatorTextButton;
///(default is middle bounds Y)
@property (nonatomic, assign) CGFloat indicatorPoistionY;

- (void)showIndicatorTextWith:(NSString *)text;
- (void)showIndicatorTextWith:(NSString *)text clickBlock:(void(^)(UIButton *sender))block;
- (void)hideIndicatorText;

- (void)startActivityAnimation;
- (void)startActivityAnimationWithType:(ActivityIndicatorType)type;
- (void)stopActivityAnimation;

- (BOOL)isActivityAnimating;

- (void)resetActivityPositions;
@end
