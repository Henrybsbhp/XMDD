//
//  WaterWaveProgressView.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "WaterWaveProgressView.h"
#import "AhaWaterWaveView.h"
#import "MutualInsConstants.h"

#define kInnerSpacing       8
#define kWaveAmplitude      5
#define kWaveOffset         0.6
#define kWaveSpeed          5

@interface WaterWaveProgressView ()
@property (nonatomic, strong) AhaWaterWaveView *wave1;
@property (nonatomic, strong) AhaWaterWaveView *wave2;
@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, strong) UIImageView *arcView;
@end

@implementation WaterWaveProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit:self.frame];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit:self.frame];
    }
    return self;
}

- (void)commonInit:(CGRect)frame
{
    //内部水球视图
    CGRect rect = CGRectMake(kInnerSpacing, kInnerSpacing, frame.size.width-2*kInnerSpacing, frame.size.height-2*kInnerSpacing);
    _innerView = [[UIView alloc] initWithFrame:rect];
    _innerView.layer.cornerRadius = rect.size.width/2;
    _innerView.layer.masksToBounds = YES;
    _innerView.layer.borderColor = [kDefTintColor CGColor];
    _innerView.layer.borderWidth = 1;
    [self addSubview:_innerView];
    
    rect.origin = CGPointZero;
    //波浪线1
    _wave1 = [[AhaWaterWaveView alloc] initWithFrame:rect];
    _wave1.waveAmplitude = kWaveAmplitude;
    _wave1.waveOffset = kWaveOffset;
    _wave1.waveSpeed = kWaveSpeed;
    _wave1.waveColor = [kDefTintColor colorWithAlpha:0.6];
    [_innerView addSubview:_wave1];
    
    //波浪线2
    _wave2 = [[AhaWaterWaveView alloc] initWithFrame:rect];
    _wave2.waveAmplitude = kWaveAmplitude;
    _wave2.waveSpeed = kWaveSpeed;
    _wave2.waveColor = [kDefTintColor colorWithAlpha:0.7];
    [_innerView addSubview:_wave2];
    
    //标题
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, MAX(20, ceil(rect.size.height/2-40)), rect.size.width-40, 16)];
    _titleLable.backgroundColor = [UIColor clearColor];
    _titleLable.font = [UIFont systemFontOfSize:13];
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.textColor = kDefTintColor;
    [_innerView addSubview:_titleLable];
    
    //副标题
    _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, MAX(40, ceil(rect.size.height/2-20)), rect.size.width-20,16)];
    _subTitleLabel.backgroundColor = [UIColor clearColor];
    _subTitleLabel.font = [UIFont systemFontOfSize:12];
    _subTitleLabel.textAlignment = NSTextAlignmentCenter;
    _subTitleLabel.textColor = kDefTintColor;
    [_innerView addSubview:_subTitleLabel];
    
    //外面旋转的弧线
    self.arcView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.arcView.image = [UIImage imageNamed:@"mins_arc"];
    self.arcView.hidden = YES;
    [self addSubview:self.arcView];
    
    [self setProgress:0 withAnimation:NO];
}

- (void)setProgress:(CGFloat)progress withAnimation:(BOOL)animate
{
    _progress = progress;
    CGRect frame = _wave1.frame;
    CGFloat mid = frame.size.height/2;
    CGFloat y = floor(frame.size.height - frame.size.height * progress);
    //判断副标题位置，控制水波不出现在副标题中间
    if (y < mid-20+8 && y > mid-20-12) {
        y = mid-20-12;
    }
    else if (y > mid-20+8 && y < mid-20+14) {
        y = mid-20+14;
    }
    //判断标题位置，控制水波不出现在标题中间
    else if (y < mid-40+8 && y > mid-40-12) {
        y = mid-40-12;
    }
    else if (y > mid-40+8 && y < mid-40+14) {
        y = mid-40+14;
    }
    
    frame.origin.y = MIN(frame.size.height-8, y);
    if (animate) {
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _wave1.frame = frame;
            _wave2.frame = frame;
        } completion:nil];
    }
    else {
        _wave1.frame = frame;
        _wave2.frame = frame;
    }
    [self setLabel:self.subTitleLabel color:(y <= frame.size.height/2-20) ? [UIColor whiteColor] : kDefTintColor  animate:animate];
    [self setLabel:self.titleLable color:(y <= frame.size.height/2-40) ? [UIColor whiteColor] : kDefTintColor  animate:animate];
}

- (void)startWave
{
    [_wave1 waveStart];
    [_wave2 waveStart];
}

- (void)stopWave
{
    [_wave1 waveStop];
    [_wave2 waveStop];
}

- (void)showArcLightOnce
{
    self.arcView.transform = CGAffineTransformIdentity;
    self.arcView.hidden = NO;
    
    CABasicAnimation *opacity1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity1.fillMode = kCAFillModeForwards;
    opacity1.removedOnCompletion = NO;
    opacity1.fromValue = @0;
    opacity1.toValue = @1.0;
    opacity1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    opacity1.duration = 0.1;
    
    CABasicAnimation *opacity2 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity2.fillMode = kCAFillModeForwards;
    opacity2.removedOnCompletion = NO;
    opacity2.fromValue = @1.0;
    opacity2.toValue = @0;
    opacity2.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    opacity2.duration = 0.2;
    opacity2.beginTime = 0.9;
    
    CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotate.toValue = @(M_PI*2);
    rotate.duration = 0.85;
    rotate.beginTime = 0.05;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 1.1;
    group.animations = @[opacity1,opacity2,rotate];
    
    [self.arcView.layer addAnimation:group forKey:@"rotaionAnimation"];
    self.arcView.layer.opacity = 0;
}
#pragma mark - Util
- (void)setLabel:(UILabel *)label color:(UIColor *)color animate:(BOOL)animate
{
    if ([label.textColor isEqual:color]) {
        return;
    }
    if (animate) {
        [UIView transitionWithView:label duration:1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            label.textColor = color;
        } completion:nil];
    }
    else {
        label.textColor = color;
    }
}

@end
