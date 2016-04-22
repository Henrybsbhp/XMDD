//
//  PullDownAnimationButton.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PullDownAnimationButton.h"
#import "MutualInsConstants.h"

#define kAnimationDuration      0.24

@interface PullDownAnimationButton ()

@property (nonatomic, strong) CAShapeLayer *line1Layer;
@property (nonatomic, strong) CAShapeLayer *line2Layer;
@property (nonatomic, strong) CAShapeLayer *line3Layer;
@property (nonatomic, strong) CAShapeLayer *line4Layer;

@end

@implementation PullDownAnimationButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitWithFrame:self.frame];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitWithFrame:frame];
    }
    return self;
}

- (void)commonInitWithFrame:(CGRect)frame
{
    _line1Layer = [self createBaseShapeLayerWithFrame:frame];
    _line2Layer = [self createBaseShapeLayerWithFrame:frame];
    _line3Layer = [self createBaseShapeLayerWithFrame:frame];
    _line4Layer = [self createBaseShapeLayerWithFrame:frame];
    [self setPulled:NO withAnimation:NO];
}


- (void)setPulled:(BOOL)pulled withAnimation:(BOOL)animate
{
    _pulled = pulled;
    CGPathRef path1, path2, path3, path4;
    if (!pulled) {
        path1 = [self pathWithStartPoint:CGPointMake(0, 6) endPoint:CGPointMake(12, 6)];
        path2 = [self pathWithStartPoint:CGPointMake(12, 6) endPoint:CGPointMake(24, 6)];
        path3 = [self pathWithStartPoint:CGPointMake(0, 12) endPoint:CGPointMake(12, 12)];
        path4 = [self pathWithStartPoint:CGPointMake(12, 12) endPoint:CGPointMake(24, 12)];
    }
    else {
        path1 = [self pathWithStartPoint:CGPointMake(0, 6) endPoint:CGPointMake(12, 1)];
        path2 = [self pathWithStartPoint:CGPointMake(12, 1) endPoint:CGPointMake(24, 6)];
        path3 = [self pathWithStartPoint:CGPointMake(0, 12) endPoint:CGPointMake(12, 7)];
        path4 = [self pathWithStartPoint:CGPointMake(12, 7) endPoint:CGPointMake(24, 12)];
    }
    
    if (animate) {
        [self addAnimationForLayer:self.line1Layer toPath:path1];
        [self addAnimationForLayer:self.line2Layer toPath:path2];
        [self addAnimationForLayer:self.line3Layer toPath:path3];
        [self addAnimationForLayer:self.line4Layer toPath:path4];
    }
    else {
        self.line1Layer.path = path1;
        self.line2Layer.path = path2;
        self.line3Layer.path = path3;
        self.line4Layer.path = path4;
    }
}

#pragma mark - Util
- (CAShapeLayer *)createBaseShapeLayerWithFrame:(CGRect)frame
{
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = CGRectMake(0, 0, 24, 12);
    layer.lineJoin = kCALineJoinRound;
    layer.lineCap = kCALineCapRound;
    layer.fillColor = [[UIColor clearColor] CGColor];
    layer.lineWidth = 2;
    layer.strokeColor = [kLightLineColor CGColor];
    layer.position = CGPointMake(frame.size.width/2, frame.size.height/2);
    [self.layer addSublayer:layer];
    
    return layer;
}

- (CGPathRef)pathWithStartPoint:(CGPoint)point endPoint:(CGPoint)end
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point];
    [path addLineToPoint:end];
    [path closePath];
    return [path CGPath];
}

- (CABasicAnimation *)addAnimationForLayer:(CAShapeLayer *)layer toPath:(CGPathRef)path
{
    [layer removeAllAnimations];
    CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"path"];
    animate.fillMode = kCAFillModeForwards;
    animate.removedOnCompletion = NO;
    animate.duration = kAnimationDuration;
    animate.fromValue = (__bridge id)(layer.path);
    animate.toValue = (__bridge id)(path);
    [animate setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [layer addAnimation:animate forKey:@"line"];
    layer.path = path;
    return animate;
}

@end
