//
//  DrawingBoardView.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DrawingBoardView.h"

@implementation DrawingBoardView

- (void)drawSuccess
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    CAShapeLayer *arcLayer = [CAShapeLayer layer];
    
    [path addArcWithCenter:CGPointMake(65, 50) radius:45 startAngle:0 endAngle:2*M_PI clockwise:NO];
    [path moveToPoint:CGPointMake(43, 50)];
    [path addLineToPoint:CGPointMake(63, 68)];
    [path addLineToPoint:CGPointMake(88, 35)];
    arcLayer = [CAShapeLayer layer];
    arcLayer.path = path.CGPath;
    arcLayer.fillColor = [UIColor clearColor].CGColor;
    arcLayer.strokeColor = [UIColor colorWithHex:@"#20ab2a" alpha:1.0f].CGColor;
    arcLayer.lineWidth = 2.5;
    [self.layer addSublayer:arcLayer];
    [self drawLineAnimation:arcLayer];
}

- (void)drawFailure
{
    UIBezierPath *path=[UIBezierPath bezierPath];
    CAShapeLayer *arcLayer = [CAShapeLayer layer];
    
    [path addArcWithCenter:CGPointMake(65, 50) radius:45 startAngle:0 endAngle:2*M_PI clockwise:NO];
    [path moveToPoint:CGPointMake(50, 37)];
    [path addLineToPoint:CGPointMake(80, 67)];
    [path moveToPoint:CGPointMake(80, 37)];
    [path addLineToPoint:CGPointMake(50, 67)];
    arcLayer = [CAShapeLayer layer];
    arcLayer.path = path.CGPath;
    arcLayer.fillColor = [UIColor clearColor].CGColor;
    arcLayer.strokeColor = [UIColor colorWithHex:@"#e72c2c" alpha:1.0f].CGColor;
    arcLayer.lineWidth = 2.5;
    [self.layer addSublayer:arcLayer];
    [self drawLineAnimation:arcLayer];
}

-(void)drawLineAnimation:(CALayer*)layer
{
    CABasicAnimation *bas=[CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    bas.duration=0.8;
    bas.delegate=self;
    bas.fromValue=[NSNumber numberWithInteger:0];
    bas.toValue=[NSNumber numberWithInteger:1];
    [layer addAnimation:bas forKey:@"key"];
}

@end
