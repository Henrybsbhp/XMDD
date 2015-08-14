//
//  UIScrollView+RefreshView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UIScrollView+RefreshView.h"

static char kRefreshViewKey;

@implementation UIScrollView (RefreshView)
@dynamic refreshView;

- (HKRefreshControl *)refreshView
{
    HKRefreshControl *refreshView = objc_getAssociatedObject(self, &kRefreshViewKey);
    if (!refreshView) {
        refreshView = [[HKRefreshControl alloc] initWithScrollView:self];
        objc_setAssociatedObject(self, &kRefreshViewKey, refreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        [self addSubview:refreshView];
//        [refreshView setColors:@[kDefTintColor]];
    }
    return refreshView;
}

- (void)restartRefreshViewAnimatingWhenRefreshing
{
    HKRefreshControl *refreshView = objc_getAssociatedObject(self, &kRefreshViewKey);
    [refreshView restartAnimatingIfNeeded];
}

@end
