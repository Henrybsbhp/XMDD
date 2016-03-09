//
//  HKArrowView.m
//  XiaoMa
//
//  Created by jt on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKArrowView.h"

@implementation HKArrowView

- (void)dealloc
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _bgColor = [UIColor colorWithHex:@"#18d06a" alpha:1.0f];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat arrowWidth = height / 2;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, _bgColor.CGColor);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, &CGAffineTransformIdentity, 0 , 0);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, width - arrowWidth, 0);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity,width, height / 2);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, width - arrowWidth, height);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, 0, height);
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    
    CGContextFillPath(ctx);
    
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(width - arrowWidth, height / 2 - 1, 2, 2));//画实心圆,参数2:圆坐标。可以是椭圆
}

@end
