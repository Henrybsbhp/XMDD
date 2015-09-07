//
//  DashLine.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DashLine.h"

@implementation DashLine

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

- (void)dealloc
{
    free(self.dashLengths);
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.lineColor = HEXCOLOR(@"#cdd3da");
    CGFloat* lengths = malloc(sizeof(CGFloat)*2);
    lengths[0] = 8;
    lengths[1] = 2;
    self.dashLengths = lengths;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextBeginPath(ctx);
    CGContextSetStrokeColorWithColor(ctx, self.lineColor.CGColor);
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetLineDash(ctx, 0, self.dashLengths, 2);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, self.vertical ? 0 : rect.size.width, self.vertical ? rect.size.height : 0);
    CGContextStrokePath(ctx);
    CGContextClosePath(ctx);
}


@end
