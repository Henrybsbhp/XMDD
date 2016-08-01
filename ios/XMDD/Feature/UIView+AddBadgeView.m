//
//  UIView+AddBadgeView.m
//  JTNewReader
//
//  Created by jiangjunchen on 14-4-3.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIView+AddBadgeView.h"
#import <objc/runtime.h>

static const char kBadgeViewKey;

@implementation UIView (AddBadgeView)
@dynamic badgeView;

- (JTImageBadge *)badgeView
{
    JTImageBadge *badgeView = objc_getAssociatedObject(self, &kBadgeViewKey);
    if (!badgeView)
    {
        badgeView = [[JTImageBadge alloc] initWithFrame:CGRectZero];
        badgeView.center = CGPointMake(0, 0);
        objc_setAssociatedObject(self, &kBadgeViewKey, badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self addSubview:badgeView];
    }
    return badgeView;
}

- (void)setBadgeView:(JTImageBadge *)badgeView
{
    objc_setAssociatedObject(self, &kBadgeViewKey, badgeView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)hasBadgeView
{
    return (BOOL)objc_getAssociatedObject(self, &kBadgeViewKey);
}

@end
