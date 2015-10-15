//
//  CKLine.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CKLine.h"

@implementation CKLine

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.lineColor = [UIColor grayColor];
    self.linePixelWidth = 1;
    self.linePointWidth = 1;
    self.lineAlignment = CKLineAlignmentHorizontalTop;
    self.pixelMode = NO;
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat lineWidth = self.pixelMode ? self.linePixelWidth/[UIScreen mainScreen].scale : self.linePointWidth;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //关闭抗锯齿
    CGContextSetAllowsAntialiasing(ctx,NO);
    CGContextBeginPath(ctx);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, lineWidth);
    CGFloat x1 = self.lineAlignment == CKLineAlignmentVerticalRight ? rect.size.width : 0;
    CGFloat y1 = self.lineAlignment == CKLineAlignmentHorizontalBottom ? rect.size.height : 0;
    CGFloat x2 = self.lineAlignment > 0 ? rect.size.width : x1;
    CGFloat y2 = self.lineAlignment < 0 ? rect.size.height : y1;
    CGContextMoveToPoint(ctx, x1, y1);
    CGContextAddLineToPoint(ctx, x2, y2);
    CGContextStrokePath(ctx);
}

@end
