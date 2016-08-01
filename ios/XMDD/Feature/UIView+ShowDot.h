//
//  UIView+ShowDot.h
//  Shopper
//
//  Created by jiangjunchen on 14/12/10.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ShowDot)

- (void)showDotWithOffset:(CGPoint)offset;
- (void)showDotWithOffset:(CGPoint)offset withBoardLine:(BOOL)board;
- (void)hideDot;

@end
