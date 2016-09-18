//
//  UIView+ShowDot.h
//  Shopper
//
//  Created by jiangjunchen on 14/12/10.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTImageBadge.h"

@interface UIView (ShowDot)

- (void)showDotWithOffset:(CGPoint)offset withBadge:(JTImageBadge *)badge;
- (void)showDotWithOffset:(CGPoint)offset withBoardLine:(BOOL)board withBadge:(JTImageBadge *)badge;
- (void)hideDotWithBadge:(JTImageBadge *)badge;

@end
