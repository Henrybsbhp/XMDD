//
//  UIView+Layer.m
//  XiaoNiuClient
//
//  Created by jiangjunchen on 14-6-8.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "UIView+Layer.h"
#import "Xmdd.h"

@implementation UIView (Layer)

- (void)makeCornerRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
}

- (void)showBorderLineWithDirectionMask:(NSUInteger)mask
{
    [self _resetBorderLineForDirection:CKViewBorderDirectionLeft withMask:mask];
    [self _resetBorderLineForDirection:CKViewBorderDirectionRight withMask:mask];
    [self _resetBorderLineForDirection:CKViewBorderDirectionTop withMask:mask];
    [self _resetBorderLineForDirection:CKViewBorderDirectionBottom withMask:mask];
}

- (void)setBorderLineInsets:(UIEdgeInsets)insets
{
    [self.customInfo safetySetObject:[NSValue valueWithUIEdgeInsets:insets] forKey:@"CKBorderLineInsets"];
}

- (void)setBorderLineInsets:(UIEdgeInsets)insets forDirectionMask:(NSUInteger)mask
{
    [self _resetBorderLineInset:insets forDirection:CKViewBorderDirectionLeft withMask:mask];
    [self _resetBorderLineInset:insets forDirection:CKViewBorderDirectionRight withMask:mask];
    [self _resetBorderLineInset:insets forDirection:CKViewBorderDirectionTop withMask:mask];
    [self _resetBorderLineInset:insets forDirection:CKViewBorderDirectionBottom withMask:mask];
}

- (void)setBorderLineColor:(UIColor *)color forDirectionMask:(NSUInteger)mask
{
    [self _resetBorderLineColor:color forDirection:CKViewBorderDirectionLeft withMask:mask];
    [self _resetBorderLineColor:color forDirection:CKViewBorderDirectionRight withMask:mask];
    [self _resetBorderLineColor:color forDirection:CKViewBorderDirectionTop withMask:mask];
    [self _resetBorderLineColor:color forDirection:CKViewBorderDirectionBottom withMask:mask];
}

- (UIColor *)borderLineColorForDirection:(CKViewBorderDirection)direction
{
    return [[self _borderLineColorTupleForDirection:direction] second];
}

- (void)layoutBorderLineIfNeeded
{
    [self _layoutBorderLineForDirection:CKViewBorderDirectionLeft];
    [self _layoutBorderLineForDirection:CKViewBorderDirectionRight];
    [self _layoutBorderLineForDirection:CKViewBorderDirectionTop];
    [self _layoutBorderLineForDirection:CKViewBorderDirectionBottom];
}

#pragma mark - Utilities
- (void)_resetBorderLineForDirection:(CKViewBorderDirection)direction withMask:(NSUInteger)mask
{
    NSString *key = [NSString stringWithFormat:@"CKBorderLine_%d", (int)direction];
    UIImageView *imgV = self.customInfo[key];
    if (mask & direction) {
        if (!imgV) {
            imgV = [[UIImageView alloc] initWithFrame:CGRectZero];
            self.customInfo[key] = imgV;
            [self addSubview:imgV];
        }
    }
    else {
        if (imgV) {
            [self.customInfo removeObjectForKey:key];
            [imgV removeFromSuperview];
        }
    }
}

- (void)_resetBorderLineColor:(UIColor *)color forDirection:(CKViewBorderDirection)direction withMask:(NSUInteger)mask
{
    if (mask & direction) {
        NSString *key = [NSString stringWithFormat:@"CKBorderLineColor_%d", (int)direction];
        UIImage *img = [UIImage imageWithColor:color size:CGSizeMake(1, 1)];
        RACTuple *tuple = RACTuplePack(color, img);
        [self.customInfo safetySetObject:tuple forKey:key];
    }
}

- (void)_resetBorderLineInset:(UIEdgeInsets)inset forDirection:(CKViewBorderDirection)direction withMask:(NSUInteger)mask
{
    if (mask & direction) {
        NSString *key = [NSString stringWithFormat:@"CKBorderLineInset_%d", (int)direction];
        [self.customInfo safetySetObject:[NSValue valueWithUIEdgeInsets:inset] forKey:key];
    }
}

- (RACTuple *)_borderLineColorTupleForDirection:(CKViewBorderDirection)direction
{
    NSString *key = [NSString stringWithFormat:@"CKBorderLineColor_%d", (int)direction];
    RACTuple *tuple = self.customInfo[key];
    if (!tuple) {
        [self setBorderLineColor:[UIColor colorWithHex:@"#d1d1d1" alpha:1.0f] forDirectionMask:direction];
        tuple = self.customInfo[key];
    }
    return tuple;
}

- (void)_layoutBorderLineForDirection:(CKViewBorderDirection)direction
{
    NSString *key = [NSString stringWithFormat:@"CKBorderLine_%d", (int)direction];
    UIImageView *imgV = self.customInfo[key];
    if (!imgV) {
        return;
    }
    imgV.image = [self _borderLineColorTupleForDirection:direction].second;
    CGRect frame;
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    NSValue *insetValue = self.customInfo[@"CKBorderLineInsets"];
    if (!insetValue) {
        NSString *insetKey = [NSString stringWithFormat:@"CKBorderLineInset_%d", (int)direction];
        insetValue = self.customInfo[insetKey];
    }
    UIEdgeInsets insets = [insetValue UIEdgeInsetsValue];
    switch (direction) {
        case CKViewBorderDirectionTop:
            frame = CGRectMake(insets.left, insets.top, width-insets.left-insets.right, 1);
            break;
        case CKViewBorderDirectionLeft:
            frame = CGRectMake(insets.left, insets.top, 1, height-insets.top-insets.bottom);
            break;
        case CKViewBorderDirectionRight:
            frame = CGRectMake(width-insets.right-1, insets.top, 1, height-insets.top-insets.bottom);
            break;
        default:
            frame = CGRectMake(insets.left, height-insets.bottom-1, width-insets.left-insets.right, 1);
            break;
    }
    imgV.frame = frame;
    if (!imgV.superview) {
        [self addSubview:imgV];
    }
    else {
        [self bringSubviewToFront:imgV];
    }
}

///截图
- (UIImage *)snapshotWithEdgeInsets:(UIEdgeInsets)insets
{
    // Create a graphics context with the target size
    CGSize imageSize = self.bounds.size;
    imageSize = imageSize;
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(insets.left, insets.top,
                             imageSize.width-insets.left-insets.right,
                             imageSize.height-insets.top-insets.bottom);
    CGContextClipToRect(context, rect);
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    }
    else {
        [[self layer] renderInContext:context];
    }
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
