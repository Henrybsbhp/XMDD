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
    self.lineColor = HEXCOLOR(@"#E3E3E3");
    self.linePixelWidth = 1;
    self.linePointWidth = 1;
    self.lineAlignment = CKLineAlignmentHorizontalTop;
    self.lineOptions = CKLineOptionNone;
    self.dashLengths = @[@8, @2];
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat lineWidth = self.lineOptions & CKLineOptionPixel ? self.linePixelWidth/[UIScreen mainScreen].scale : self.linePointWidth;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //关闭抗锯齿
    CGContextSetAllowsAntialiasing(ctx,NO);
    CGContextBeginPath(ctx);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    //设置虚线
    if (self.lineOptions & CKLineOptionDash) {
        CGFloat dashLengths[2] = {[self.dashLengths[0] floatValue], [self.dashLengths[1] floatValue]};
        CGContextSetLineDash(ctx, 0,  dashLengths, 2);
    }
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
