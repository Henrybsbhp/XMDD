//
//  UIView+JTLoadingView.m
//  XiaoNiuShared
//
//  Created by jiangjunchen on 14-7-5.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIView+JTLoadingView.h"
#import <objc/runtime.h>
#import "CKKit.h"
#import <UIKitExtension.h>
#import "GifActivityIndicatorView.h"

@implementation UIView (JTLoadingView)
@dynamic activityIndicatorView;
@dynamic indicatorTextButton;
@dynamic indicatorPoistionY;

static char sIndicatorPoistionYKey;
static char sActivityIndicatorView;

- (UIView *)activityIndicatorView
{
    return objc_getAssociatedObject(self, &sActivityIndicatorView);
}

- (void)setActivityIndicatorView:(UIView *)activityIndicatorView
{
    objc_setAssociatedObject(self, &sActivityIndicatorView, activityIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIButton *)indicatorTextButton
{
    UIButton *btn = objc_getAssociatedObject(self, _cmd);
    if (!btn)
    {
        btn = [[UIButton alloc] initWithFrame:CGRectZero];
        [btn addTarget:self action:@selector(_actionIndicatorTextClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        [btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor clearColor];
        btn.hidden = YES;
        [self addSubview:btn];
        objc_setAssociatedObject(self, _cmd, btn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return btn;
}

- (CGFloat)indicatorPoistionY
{
    NSNumber *numY = objc_getAssociatedObject(self, &sIndicatorPoistionYKey);
    if (!numY)
    {
        CGFloat y = CGRectGetMidY(self.bounds);
        [self setIndicatorPoistionY:y];
        return y;
    }
    return [numY floatValue];
}

- (void)setIndicatorPoistionY:(CGFloat)indicatorPoistionY
{
    objc_setAssociatedObject(self, &sIndicatorPoistionYKey,
                             @(indicatorPoistionY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showIndicatorTextWith:(NSString *)text
{
    [self showIndicatorTextWith:text clickBlock:nil];
}

- (void)_actionIndicatorTextClick:(id)sender
{
    if (self.indicatorTextButton.customActionBlock)
    {
        self.indicatorTextButton.customActionBlock();
    }
}

- (void)showIndicatorTextWith:(NSString *)text clickBlock:(void(^)(UIButton *sender))block
{
    BOOL isAnimating = [self isActivityAnimating];
    CGFloat y = isAnimating ? CGRectGetMaxY(self.activityIndicatorView.frame) : self.indicatorPoistionY -18;
    self.indicatorTextButton.frame = CGRectMake(0, y, self.frame.size.width, 36);
    [self.indicatorTextButton setTitle:text forState:UIControlStateNormal];
    [self.indicatorTextButton.titleLabel setFont:[UIFont systemFontOfSize:14]];
    //    [self.indicatorTextButton sizeToFit];
    self.indicatorTextButton.hidden = NO;
    @weakify(self);
    [self.indicatorTextButton setCustomActionBlock:^{
        if (block) {
            @strongify(self);
            block(self.indicatorTextButton);
        }
    }];
    [self bringSubviewToFront:self.indicatorTextButton];
}

- (void)hideIndicatorText
{
    self.indicatorTextButton.hidden = YES;
}

- (void)startActivityAnimation
{
    [self startActivityAnimationWithType:MONActivityIndicatorType];
}

- (void)startActivityAnimationWithType:(ActivityIndicatorType)type
{
    CGPoint position = CGPointMake(self.frame.size.width/2, self.indicatorPoistionY);
    [self startActivityAnimationWithType:type atPositon:position autoResize:YES];
}

- (void)startActivityAnimationWithType:(ActivityIndicatorType)type atPositon:(CGPoint)position
{
    [self startActivityAnimationWithType:type atPositon:position autoResize:NO];
}

- (void)startActivityAnimationWithType:(ActivityIndicatorType)type atPositon:(CGPoint)position autoResize:(BOOL)autoResize
{
    if (type == MONActivityIndicatorType)
    {
        if (![self.activityIndicatorView isKindOfClass:[MONActivityIndicatorView class]])
        {
            [self.activityIndicatorView removeFromSuperview];
            MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
            indicatorView.delegate = self;
            indicatorView.numberOfCircles = 5;
            indicatorView.radius = 5;
            indicatorView.internalSpacing = 2;
            indicatorView.hidden = YES;
            [self addSubview:indicatorView];
            self.activityIndicatorView = indicatorView;
        }
        
        [(MONActivityIndicatorView *)self.activityIndicatorView startAnimating];
    }
    else if (type == TYMActivityIndicatorType)
    {
        if (![self.activityIndicatorView isKindOfClass:[TYMActivityIndicatorView class]])
        {
            [self.activityIndicatorView removeFromSuperview];
            TYMActivityIndicatorView *view = [[TYMActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:TYMActivityIndicatorViewStyleNormal];
            view.fullRotationDuration = 0.7;
            view.indicatorImage = [view.indicatorImage imageByFilledWithColor:RGBACOLOR(255, 135, 0, 1.0)];
            view.hidesWhenStopped = YES;
            view.hidden = YES;
            [self addSubview:view];
            self.activityIndicatorView = view;
        }
        [(TYMActivityIndicatorView *)self.activityIndicatorView startAnimating];
    }
    else if (type == UIActivityIndicatorType)
    {
        if (![self.activityIndicatorView isKindOfClass:[UIActivityIndicatorView class]])
        {
            [self.activityIndicatorView removeFromSuperview];
            UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc]
                                             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            view.hidesWhenStopped = YES;
            view.hidden = YES;
            [self addSubview:view];
            self.activityIndicatorView = view;
        }
        [(UIActivityIndicatorView *)self.activityIndicatorView startAnimating];
    }
    else {
        if (![self.activityIndicatorView isKindOfClass:[GifActivityIndicatorView class]]) {
            [self.activityIndicatorView removeFromSuperview];
            GifActivityIndicatorView *view = [[GifActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, 120)];
            view.hidden = YES;
            [self addSubview:view];
            self.activityIndicatorView = view;
        }
        [(GifActivityIndicatorView *)self.activityIndicatorView startAnimating];
    }
    if (autoResize) {
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    else {
        self.activityIndicatorView.autoresizingMask = UIViewAutoresizingNone;
    }
    self.activityIndicatorView.center = position;
    [self bringSubviewToFront:self.activityIndicatorView];
}

- (void)stopActivityAnimation
{
    if ([self.activityIndicatorView isKindOfClass:[TYMActivityIndicatorView class]])
    {
        [(TYMActivityIndicatorView *)self.activityIndicatorView stopAnimating];
    }
    else if ([self.activityIndicatorView isKindOfClass:[MONActivityIndicatorView class]])
    {
        [(MONActivityIndicatorView *)self.activityIndicatorView stopAnimating];
    }
    else if ([self.activityIndicatorView isKindOfClass:[UIActivityIndicatorView class]]) {
        [(UIActivityIndicatorView *)self.activityIndicatorView stopAnimating];
    }
    else {
        [(GifActivityIndicatorView *)self.activityIndicatorView stopAnimating];
    }
}

- (BOOL)isActivityAnimating
{
    BOOL isAnimating = NO;
    if ([self.activityIndicatorView isKindOfClass:[TYMActivityIndicatorView class]])
    {
        isAnimating = [(TYMActivityIndicatorView *)self.activityIndicatorView isAnimating];
    }
    else if ([self.activityIndicatorView isKindOfClass:[MONActivityIndicatorView class]])
    {
        isAnimating = [(MONActivityIndicatorView *)self.activityIndicatorView isAnimating];
    }
    else if ([self.activityIndicatorView isKindOfClass:[GifActivityIndicatorView class]]) {
        isAnimating = [(GifActivityIndicatorView *)self.activityIndicatorView isAnimating];
    }
    else {
        isAnimating = [(UIActivityIndicatorView *)self.activityIndicatorView isAnimating];
    }
    return isAnimating;
}

- (void)resetActivityPositions
{
    self.activityIndicatorView.center = CGPointMake(self.frame.size.width/2, self.indicatorPoistionY);
    BOOL isAnimating = [self isActivityAnimating];
    CGFloat y = isAnimating ? CGRectGetMaxY(self.activityIndicatorView.frame) : CGRectGetMidY(self.bounds)-18;
    self.indicatorTextButton.frame = CGRectMake(0, y, self.frame.size.width, 36);
}

#pragma mark - MONActivityIndicatorViewDelegate
- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index
{
    return kDefTintColor;
}
    
@end
