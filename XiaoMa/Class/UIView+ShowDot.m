//
//  UIView+ShowDot.m
//  Shopper
//
//  Created by jiangjunchen on 14/12/10.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "UIView+ShowDot.h"
#import "UIView+AddBadgeView.h"

@implementation UIView (ShowDot)

- (void)showDotWithOffset:(CGPoint)offset
{
    [self showDotWithOffset:offset withBoardLine:NO];
}

- (void)showDotWithOffset:(CGPoint)offset withBoardLine:(BOOL)board
{
    JTImageBadge *badge = self.badgeView;
    badge.frame = CGRectMake(-1, 1, 10, 10);
    badge.backgroundView.image = [UIImage imageNamed:@"cm_dot_300"];
    CGPoint center = CGPointMake(badge.center.x+offset.x, badge.center.y+offset.y);
    badge.center = center;
    if (board) {
        badge.layer.borderColor = [UIColor whiteColor].CGColor;
        badge.layer.borderWidth = 1;
        badge.layer.cornerRadius = 4;
        badge.layer.masksToBounds = YES;
    }
    badge.hidden = NO;
}

- (void)hideDot
{
    
    self.badgeView.hidden = YES;
}

@end
