//
//  HKProgressView.m
//  XiaoMa
//
//  Created by jt on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKProgressView.h"
#import "NSString+RectSize.h"

#define kArrowSpace      5
#define kArrowPeakHeight     9

@implementation HKProgressView
{
    CGFloat width;
    CGFloat height,arrowHeight;
    NSInteger count;
    CGFloat bondWidth;
    CGFloat arrowWidth;
}

- (void)dealloc
{
    
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        _highlightColor = [UIColor colorWithHex:@"#18d06a" alpha:1.0f];
        _normalColor = [UIColor colorWithHex:@"#f7f7f8" alpha:1.0f];
        _highlightTextColor = [UIColor colorWithHex:@"#ffffff" alpha:1.0f];
        _normalTextColor = [UIColor colorWithHex:@"#dbdbdb" alpha:1.0f];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    width = self.bounds.size.width;
    arrowHeight = self.bounds.size.height;
    count = _titleArray.count;
    
    bondWidth = (width - MAX(0,(count-1))*kArrowSpace - kArrowPeakHeight) / count;
    arrowWidth = bondWidth + kArrowPeakHeight;
    
    for (NSInteger i = 0; i < _titleArray.count; i++)
    {
        [self drawArrow:i];
        [self drawText:i];
    }
}

///绘制各自的箭头
- (void)drawArrow:(NSInteger)i
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIColor * color = [_selectedIndexSet containsIndex:i] ? _highlightColor : _normalColor;
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, &CGAffineTransformIdentity, (bondWidth + kArrowSpace) * i, 0);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, (bondWidth + kArrowSpace) * i + bondWidth, 0);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, (bondWidth + kArrowSpace) * i + arrowWidth, arrowHeight/2);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, (bondWidth + kArrowSpace) * i + bondWidth, arrowHeight);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, (bondWidth + kArrowSpace) * i, arrowHeight);
    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, (bondWidth + kArrowSpace) * i + kArrowPeakHeight, arrowHeight/2);
    CGPathCloseSubpath(path);
    CGContextAddPath(ctx, path);
    
    CGContextFillPath(ctx);
}

///绘制各自的文字
- (void)drawText:(NSInteger)i
{
    NSString * title = [_titleArray safetyObjectAtIndex:i];
    UIColor * color = [_selectedIndexSet containsIndex:i] ? _highlightTextColor : _normalTextColor;
    //文字样式
    UIFont *font = [UIFont systemFontOfSize:13];
    NSDictionary *dict = @{NSFontAttributeName:font,
                           NSForegroundColorAttributeName:color};
    
    CGSize size = [title labelSizeWithWidth:0.9*bondWidth font:[UIFont systemFontOfSize:13]];
    
    CGRect frame = CGRectMake((bondWidth+kArrowSpace)*i + (bondWidth+kArrowPeakHeight-size.width)/2,
                              (arrowHeight-size.height)/2 , size.width, size.height);
    [title drawInRect:frame withAttributes:dict];
}

//- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
//{
//    if (layer.customTag == _selectedIndex)
//    {
//        CGContextSetFillColorWithColor(ctx, _highlightColor.CGColor);
//    }
//    else
//    {
//        CGContextSetFillColorWithColor(ctx, _highlightColor.CGColor);
//    }
//    CGMutablePathRef path = CGPathCreateMutable();
//    
//    CGPathMoveToPoint(path, &CGAffineTransformIdentity, 0 , 0);
//    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, bondWidth, 0);
//    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, arrowWidth, arrowHeight / 2);
//    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, bondWidth, arrowHeight);
//    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, 0, arrowHeight);
//    CGPathAddLineToPoint(path, &CGAffineTransformIdentity, bondWidth / 10, arrowHeight / 2);
//    CGPathCloseSubpath(path);
//    CGContextAddPath(ctx, path);
//    
//    CGContextFillPath(ctx);
//}


- (void)setTitleArray:(NSArray *)titleArray
{
    _titleArray = titleArray;
    [self setNeedsDisplay];
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    _highlightColor = highlightColor;
    [self setNeedsDisplay];
}

- (void)setNormalColor:(UIColor *)normalColor
{
    _normalColor = normalColor;
    [self setNeedsDisplay];
}

- (void)setSelectedIndexSet:(NSIndexSet *)selectedIndexSet
{
    _selectedIndexSet = selectedIndexSet;
    [self setNeedsDisplay];
}


@end
