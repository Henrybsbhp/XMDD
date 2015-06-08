//
//  UIViewController+Coordinate.h
//  JTReader
//
//  Created by jiangjunchen on 13-10-10.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Coordinate)

- (CGFloat)baseTopY;
- (CGFloat)baseTopYWithStatusBarHide:(BOOL)statusBarHide navigatonBarHide:(BOOL)navigationBarHide;
@end
