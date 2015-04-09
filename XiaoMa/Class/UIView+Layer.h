//
//  UIView+Layer.h
//  XiaoNiuClient
//
//  Created by jiangjunchen on 14-6-8.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger
{
    CKViewBorderDirectionNone = 0,
    CKViewBorderDirectionLeft = 1 << 1,
    CKViewBorderDirectionRight = 1 << 2,
    CKViewBorderDirectionTop = 1 << 3,
    CKViewBorderDirectionBottom = 1 << 4,
    CKViewBorderDirectionAll = NSUIntegerMax
}CKViewBorderDirection;

@interface UIView (Layer)

- (void)makeCornerRadius:(CGFloat)radius;
- (void)showBorderLineWithDirectionMask:(NSUInteger)mask;
- (void)setBorderLineInsets:(UIEdgeInsets)insets;
- (void)setBorderLineInsets:(UIEdgeInsets)insets forDirectionMask:(NSUInteger)mask;
- (void)setBorderLineColor:(UIColor *)color forDirectionMask:(NSUInteger)mask;
- (UIColor *)borderLineColorForDirection:(CKViewBorderDirection)direction;
- (void)layoutBorderLineIfNeeded;

///截图
- (UIImage *)snapshotWithEdgeInsets:(UIEdgeInsets)insets;

@end
