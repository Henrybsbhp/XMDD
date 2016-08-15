//
//  HKRefreshView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKRefreshControl.h"

#define kOpenHeight 80

@interface HKRefreshControl ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, assign) BOOL insetsExpanded;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) BOOL isStartingAnimating;
@property (nonatomic, assign) BOOL shouldReset;
@property (nonatomic, assign) UIEdgeInsets originInsets;
@property (nonatomic, assign) BOOL ignoreInsets;
@end
@implementation HKRefreshControl

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
    self.scrollView = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        [self.scrollView removeObserver:self forKeyPath:@"contentInset"];
        self.scrollView = nil;
    }
}

- (id)initWithScrollView:(UIScrollView *)scrollView
{
    self = [super initWithFrame:CGRectMake(0, -scrollView.contentInset.top, scrollView.frame.size.width, 0)];
    if (self) {
        self.scrollView = scrollView;
        [self.scrollView addSubview:self];
        self.originInsets = scrollView.contentInset;
        self.clipsToBounds = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)beginRefreshing
{
    [self beginRefreshingWithComplete:nil];
}

- (void)beginRefreshingWithComplete:(void(^)(void))complete
{
    if (_refreshing) {
        return;
    }
    _refreshing = YES;
    if (!self.scrollView.dragging && !self.insetsExpanded) {
        UIEdgeInsets insets = self.originInsets;
        insets.top += kOpenHeight;
        [self setContentInset:insets];
        self.insetsExpanded = YES;
        [self updateFrameWithHeight:kOpenHeight forRefresh:NO];
    }
    else {
        [self updateFrameWithHeight:kOpenHeight forRefresh:YES];        
    }
    self.isStartingAnimating = YES;
    CGPoint pos = self.bgImgView.layer.position;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.bgImgView.frame = CGRectMake(pos.x-12, CGRectGetMaxY(self.bounds)-5-27-10, 24, 20);
    } completion:^(BOOL finished) {
        
        CGRect bounds = self.bgImgView.bounds;
        self.bgImgView.frame = CGRectMake(CGRectGetMidX(self.bounds)-27, CGRectGetMaxY(self.bounds)-5-54, 54, 54);
        
        CAKeyframeAnimation *ka1 = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
        NSMutableArray *values = [NSMutableArray array];
        [values addObject:[NSValue valueWithCGRect:bounds]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 76, 32)]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 54, 54)]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 46, 62)]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 54, 54)]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 62, 48)]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 54, 54)]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 50, 58)]];
        [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 54, 54)]];

        ka1.values = values;
        ka1.duration = 0.6;
        ka1.delegate = self;
        [self.bgImgView.layer addAnimation:ka1 forKey:@"bounds"];
    }];
    
    CKAfter(0, ^{
        if (!self.imgView) {
            self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(pos.x, CGRectGetMaxY(self.bounds)-5, 0, 0)];
            [self addSubview:self.imgView];
            UIImage *img1 = [UIImage imageNamed:@"refresh_img1"];
            UIImage *img2 = [UIImage imageNamed:@"refresh_img2"];
            self.imgView.animationImages = @[img1,img2];
            self.imgView.animationDuration = 0.6;
            self.imgView.animationRepeatCount = HUGE_VALF;
        }
        self.imgView.frame = CGRectMake(CGRectGetMidX(self.bounds), CGRectGetMaxY(self.bounds)-5, 0, 0);
        [self bringSubviewToFront:self.imgView];
        self.imgView.hidden = NO;
        [self.imgView startAnimating];

        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.imgView.frame = CGRectMake(CGRectGetMidX(self.bounds)-24, CGRectGetMaxY(self.bounds)-5-50, 48, 50);
        } completion:^(BOOL finished) {
            
            CGRect bounds = CGRectMake(0, 0, 48, 50);
            CAKeyframeAnimation *ka2 = [CAKeyframeAnimation animationWithKeyPath:@"bounds"];
            NSMutableArray *values = [NSMutableArray array];
            [values addObject:[NSValue valueWithCGRect:bounds]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 60, 40)]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 48, 50)]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 40, 58)]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 48, 50)]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 56, 42)]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 48, 50)]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 44, 54)]];
            [values addObject:[NSValue valueWithCGRect:CGRectMake(0, 0, 48, 50)]];

            
            ka2.values = values;
            ka2.duration = 0.6;
            ka2.delegate = self;
            [ka2 setValue:@100 forKey:@"tag"];
            [self.imgView.layer addAnimation:ka2 forKey:@"bounds"];
            if (complete) {
                complete();
            }
        }];
    });
}

- (void)endRefreshing
{
    [self endRefreshingWithCompletion:nil];
}

- (void)endRefreshingWithCompletion:(void(^)(void))completion
{
    if (!_refreshing || self.isAnimating) {
        return;
    }
    CKAfter(self.isStartingAnimating ? 0.6 : 0, ^{
        
        self.isAnimating = YES;
        [UIView animateWithDuration:0.25 animations:^{
            
            CGRect bounds = self.layer.bounds;
            self.bgImgView.frame = CGRectMake(CGRectGetMidX(bounds), 0, 0, 0);
            self.imgView.frame = CGRectMake(CGRectGetMidX(bounds), 0, 0, 0);
            [self setContentInset:self.originInsets];
        } completion:^(BOOL finished) {
            _refreshing = NO;
            if (!self.scrollView.dragging) {
                self.isAnimating = NO;
            }
            if (self.insetsExpanded) {
                self.insetsExpanded = NO;
                [self setContentInset:self.originInsets];
            }
            self.imgView.hidden = YES;
            if (completion) {
                completion();
            }
        }];
    });
}

- (void)restartAnimatingIfNeeded
{
    if (self.refreshing) {
        [self.imgView startAnimating];
    }
}
#pragma mark - AnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"tag"] integerValue] == 100) {
        self.isStartingAnimating = NO;
    }
}
#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath equalByCaseInsensitive:@"contentInset"]) {
        [self scrollView:self.scrollView contentInsetDidChanged:[[change objectForKey:@"new"] UIEdgeInsetsValue]];
    }
    else if ([keyPath equalByCaseInsensitive:@"contentOffset"]){
        [self scrollView:self.scrollView contentOffsetDidChanged:[[change objectForKey:@"new"] CGPointValue]];
    }
}

- (void)scrollView:(UIScrollView *)scrollView contentInsetDidChanged:(UIEdgeInsets)contentInset
{
    if (self.ignoreInsets) {
        self.ignoreInsets = NO;
        return;
    }
    self.originInsets = contentInset;
}

- (void)scrollView:(UIScrollView *)scrollView contentOffsetDidChanged:(CGPoint)contentOffset
{
    CGFloat offset = contentOffset.y+scrollView.contentInset.top;
    //被拉断了，开始刷新
    if (offset < -kOpenHeight && !_refreshing && !_isAnimating) {
        @weakify(self);
        [self beginRefreshingWithComplete:^{
            @strongify(self);
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }];
    }
    else if (offset < 0 && !_refreshing && !_isAnimating) {
        [self updateFrameWithHeight:fabs(offset) forRefresh:NO];
    }
    else if (_refreshing && offset < 0 && offset >= -kOpenHeight && !self.scrollView.dragging && !self.insetsExpanded) {
        
        self.insetsExpanded = YES;
        UIEdgeInsets insets = self.originInsets;
        insets.top += kOpenHeight;
        [self setContentInset:insets];
    }
    if (!self.scrollView.dragging && !_refreshing && self.isAnimating && offset >= 0) {
        self.isAnimating = NO;
    }
}

#pragma mark - Utility
- (void)updateFrameWithHeight:(CGFloat)height forRefresh:(BOOL)refresh
{
    CGRect frame = self.frame;
    frame.size.height = height;
    frame.origin.y = -height;
    self.frame = frame;
    if (!refresh) {
        if (!self.bgImgView) {
            self.bgImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
            [self addSubview:self.bgImgView];
            self.bgImgView.image = [UIImage imageNamed:@"refresh_bg"];
        }
        CGFloat length = MAX(0, height-10);
        frame.size = CGSizeMake(length>16 ? 16 : length, length);
        frame.origin = CGPointMake(ceil(CGRectGetMidX(self.bounds)-frame.size.width/2.0), ceil((self.frame.size.height-length)/2.0));
        self.bgImgView.frame = frame;
    }
}

- (void)setContentInset:(UIEdgeInsets)inset
{
    self.ignoreInsets = YES;
    [self.scrollView setContentInset:inset];
}

@end
