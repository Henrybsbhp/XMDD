//
//  UIScrollView+RefreshView.m
//  XiaoNiuClient
//
//  Created by jiangjunchen on 14-6-4.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIScrollView+RefreshView.h"

#import <objc/runtime.h>

@implementation UIScrollView (RefreshView)
@dynamic refreshHeaderView;

- (JTHeadRefreshView *)refreshHeaderView
{
    JTHeadRefreshView *view = objc_getAssociatedObject(self, _cmd);
    if (!view)
    {
        view = [[JTHeadRefreshView alloc] init];
        objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:view];
    }
    return view;
}

@end
