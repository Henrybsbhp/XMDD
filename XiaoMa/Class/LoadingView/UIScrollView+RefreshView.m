//
//  UIScrollView+RefreshView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UIScrollView+RefreshView.h"

@implementation UIScrollView (RefreshView)
@dynamic refreshView;

- (ODRefreshControl *)refreshView
{
    ODRefreshControl *refreshView = objc_getAssociatedObject(self, _cmd);
    if (!refreshView) {
        refreshView = [[ODRefreshControl alloc] initInScrollView:self];
        objc_setAssociatedObject(self, _cmd, refreshView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return refreshView;
}

@end
