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
    TYMActivityIndicatorType = 0,
    MONActivityIndicatorType,
    UIActivityIndicatorType,
    GifActivityIndicatorType
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

/// autoResize:YES
- (void)startActivityAnimation;
/// autoResize:YES
- (void)startActivityAnimationWithType:(ActivityIndicatorType)type;
/// autoResize:NO
- (void)startActivityAnimationWithType:(ActivityIndicatorType)type atPositon:(CGPoint)position;
- (void)startActivityAnimationWithType:(ActivityIndicatorType)type atPositon:(CGPoint)position autoResize:(BOOL)autoResize;
- (void)stopActivityAnimation;

- (BOOL)isActivityAnimating;

- (void)resetActivityPositions;

@end
