//
//  UIView+TagView.m
//  HappyTrain
//
//  Created by jt on 14-11-11.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "UIView+Base.h"

@implementation UIView (Base)

- (UIView *)searchViewWithTag:(NSInteger)tag
{
    UIView * view = [self viewWithTag:tag];
    if (!view)
    {
        for (UIView * subview in self.subviews)
        {
            view = [subview searchViewWithTag:tag];
            if (view)
            {
                return view;
            }
        }
        return nil;
    }
    return view;
}


- (void)removeSubviews
{
    NSArray * views = [self subviews];
    for (UIView * view in views)
    {
        [view removeFromSuperview];
    }
}
@end
