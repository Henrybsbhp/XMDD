//
//  HKLabel.m
//  test
//
//  Created by RockyYe on 16/3/2.
//  Copyright © 2016年 RockyYe. All rights reserved.
//

#define kWidth self.rect.size.width / 1.414

#import "HKInclinedLabel.h"

@interface HKInclinedLabel ()

@property (strong, nonatomic) UILabel *label;
@property (nonatomic) CGRect rect;

@end

@implementation HKInclinedLabel

- (void)drawRect:(CGRect)rect {
    self.rect = rect;
    [self drawTrapeziumWithRect:rect];
    
}

-(void)drawTrapeziumWithRect:(CGRect)rect
{
    self.backgroundColor = [UIColor clearColor];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width * 0.5 , 0);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height * 0.5);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextAddLineToPoint(context, 0 , 0);
    CGContextSetFillColorWithColor(context, [self.trapeziumColor CGColor]);
    CGContextFillPath(context);
    [self addSubview:self.label];
}

-(UILabel *)label
{
    if (!_label)
    {
        _label = [[UILabel alloc]initWithFrame:CGRectMake(self.rect.size.width * 0.5, 0, kWidth ,  0.5 * kWidth)];
        [self configLabelTransition];
        [self configLabelProperty];
    }
    return _label;
}

-(void)configLabelTransition
{
    CGPoint oldOrigin = _label.frame.origin;
    _label.layer.anchorPoint = CGPointMake(0, 0);
    CGPoint newOrigin = _label.frame.origin;
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    _label.center = CGPointMake (_label.center.x - transition.x + kWidth * 0.01 , _label.center.y - transition.y - kWidth * 0.01);
    
    _label.transform = CGAffineTransformRotate(self.label.transform, M_PI_4);
}

-(void)configLabelProperty
{
    _label.text = self.text;
    _label.textColor = self.textColor;
    if (self.fontSize == 0)
    {
        [_label setAdjustsFontSizeToFitWidth:YES];
    }
    else
    {
        [_label setAdjustsFontSizeToFitWidth:NO];
        _label.font = [UIFont systemFontOfSize:self.fontSize];
    }
    _label.textAlignment = NSTextAlignmentCenter;
    
}


@end
