//
//  GradientView.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/7.
//  Copyright © 2016年 huika. All rights reserved.
//



#import "GradientView.h"
#import "POP.h"

@interface GradientView()

@property (strong, nonatomic) CAShapeLayer *backgroundArc;
@property (strong, nonatomic) CAShapeLayer *finishArc;
@property (strong, nonatomic) CAGradientLayer *colorLayer;

@property (strong, nonatomic) UILabel *percentLabel;
@property (strong, nonatomic) UILabel *totalpoolamtLabel;
@property (strong, nonatomic) UILabel *presentpoolamtLabel;

@end

@implementation GradientView


- (void)drawRect:(CGRect)rect
{
    [self drawArc];
    
    [self drawLabel];
}

#pragma mark - Utility

-(void)drawLabel
{
    [self totalpoolamtLabel];
    
    [self presentpoolamtLabel];
    
    [self percentLabel];
}

-(void)drawArc
{
    [self.layer addSublayer:self.backgroundArc];
    
    [self.colorLayer setMask:self.finishArc];
    
    [self.layer addSublayer:self.colorLayer];
}

-(UIColor *)gradientColorWithPercent:(CGFloat)percent
{
    UIColor *currentColor = RGBCOLOR(24 - percent, 208 + percent * 30, 106 + 119 * percent);
    return currentColor;
}

-(void)setPercent:(NSString *)percent
{
    _percent = percent;
    CGFloat percentValue = [percent floatValue] / 100;
    
    NSString *percentStr = [NSString stringWithFormat:@"%@%%", percent];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:percentStr];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(percentStr.length-1, 1)];
    self.percentLabel.attributedText = attStr;
    self.percentLabel.textColor = [self gradientColorWithPercent:percentValue];
    self.finishArc.strokeEnd = percentValue;
}

-(void)setTotalpoolamt:(NSString *)totalpoolamt
{
    _totalpoolamt = totalpoolamt;
    
    NSString *totalpoolamtStr = [NSString stringWithFormat:@"互助金总额:%@",totalpoolamt];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:totalpoolamtStr];
    [attStr addAttributes:@{NSForegroundColorAttributeName: HEXCOLOR(@"#454545"),
                            NSFontAttributeName: [UIFont systemFontOfSize:14]} range:NSMakeRange(0, 6)];
    self.totalpoolamtLabel.textColor = HEXCOLOR(@"#FF7428");
    self.totalpoolamtLabel.attributedText = attStr;
}

-(void)setPresentpoolamt:(NSString *)presentpoolamt
{
    _presentpoolamt = presentpoolamt;
    self.presentpoolamtLabel.text = [NSString stringWithFormat:@"%@", presentpoolamt];
}

#pragma mark - LazyLoad

-(UILabel *)totalpoolamtLabel
{
    if (!_totalpoolamtLabel)
    {
        _totalpoolamtLabel = [[UILabel alloc]init];
        _totalpoolamtLabel = [[UILabel alloc]init];
        _totalpoolamtLabel.textColor = HEXCOLOR(@"#454545");
        _totalpoolamtLabel.text = [NSString stringWithFormat:@"互助金总额:%.2f",0.00];
        _totalpoolamtLabel.textAlignment = NSTextAlignmentCenter;
        _totalpoolamtLabel.font = [UIFont systemFontOfSize:13];
        [_totalpoolamtLabel setAdjustsFontSizeToFitWidth:YES];
        [self addSubview:_totalpoolamtLabel];

        [_totalpoolamtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.bottom.mas_equalTo(-47);
            make.left.mas_equalTo(40);
            make.right.mas_equalTo(-40);
        }];
    }
    return _totalpoolamtLabel;
}

-(UILabel *)presentpoolamtLabel
{
    if (!_presentpoolamtLabel)
    {
        
        UILabel *noticLabel = [[UILabel alloc]init];
        noticLabel.textColor = kGrayTextColor;
        noticLabel.text = @"互助金剩余";
        noticLabel.textAlignment = NSTextAlignmentCenter;
        noticLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:noticLabel];
        [noticLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(-32);
        }];
        
        _presentpoolamtLabel = [[UILabel alloc]init];
        _presentpoolamtLabel.textColor = HEXCOLOR(@"#454545");
        _presentpoolamtLabel.text = [NSString stringWithFormat:@"%.2f",0.00];
        _presentpoolamtLabel.textAlignment = NSTextAlignmentCenter;
        _presentpoolamtLabel.font = [UIFont systemFontOfSize:43];
        [self addSubview:_presentpoolamtLabel];
        [_presentpoolamtLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
        }];
        
    }
    return _presentpoolamtLabel;
}

-(UILabel *)percentLabel
{
    if (!_percentLabel)
    {
        _percentLabel = [[UILabel alloc]init];
        _percentLabel.font = [UIFont systemFontOfSize:24];
        _percentLabel.textAlignment = NSTextAlignmentCenter;
        
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:@"0%"];
        
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(1, 1)];
        
        _percentLabel.attributedText = attStr;
        _percentLabel.textColor = HEXCOLOR(@"#18D06A");
        [self addSubview:_percentLabel];
        
        [_percentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(15);
            make.centerX.mas_equalTo(6);
        }];
    }
    return _percentLabel;
}

-(CAShapeLayer *)finishArc
{
    if (!_finishArc)
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = MIN(self.bounds.size.width/2, self.bounds.size.height/2);
        [path addArcWithCenter:center radius:radius-10 startAngle:-M_PI_2 endAngle:2 * M_PI -M_PI_2 clockwise:YES];
        
        _finishArc = [[CAShapeLayer alloc]init];
        _finishArc.frame = self.bounds;
        _finishArc.lineWidth = 4;
        _finishArc.path = path.CGPath;
        _finishArc.fillColor =  [[UIColor clearColor] CGColor];
        _finishArc.strokeColor = [HEXCOLOR(@"#f7f7f8") CGColor];
        _finishArc.strokeEnd = 0;
    }
    return _finishArc;
    
}

-(CAShapeLayer *)backgroundArc
{
    if (!_backgroundArc)
    {
        UIBezierPath *path = [UIBezierPath bezierPath];
        CGPoint center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        CGFloat radius = MIN(self.bounds.size.width/2, self.bounds.size.height/2);
        [path addArcWithCenter:center radius:radius-10 startAngle: 0 endAngle:2 * M_PI clockwise:YES];
        
        _backgroundArc = [[CAShapeLayer alloc]init];
        _backgroundArc.frame = self.bounds;
        _backgroundArc.lineWidth = 2.5;
        _backgroundArc.path = path.CGPath;
        _backgroundArc.fillColor =  [[UIColor clearColor] CGColor];
        _backgroundArc.strokeColor = [HEXCOLOR(@"#f7f7f8") CGColor];
        _backgroundArc.strokeEnd = 1;
    }
    return _backgroundArc;
    
}

-(CAGradientLayer *)colorLayer
{
    if (!_colorLayer)
    {
        _colorLayer = [CAGradientLayer layer];
        
        _colorLayer.frame    = (CGRect){CGPointZero, CGSizeMake(self.bounds.size.width, self.bounds.size.height)};
        _colorLayer.colors = @[(__bridge id)HEXCOLOR(@"#17EEE1").CGColor,
                              (__bridge id)HEXCOLOR(@"#18D06A").CGColor];
        _colorLayer.locations  = @[@(0.25)];
        _colorLayer.startPoint = CGPointMake(0, 0);
        _colorLayer.endPoint   = CGPointMake(1, 0);
    }
    return _colorLayer;
}

- (void)setPercent:(NSString *)percent animate:(BOOL)animate {
    _percent = percent;
    CGFloat percentValue = [percent floatValue] / 100;
    
    NSString *percentStr = [NSString stringWithFormat:@"%@%%", percent];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:percentStr];
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16.0] range:NSMakeRange(percentStr.length-1, 1)];
    self.percentLabel.attributedText = attStr;
    self.percentLabel.textColor = [self gradientColorWithPercent:percentValue];
    
    if (animate) {
//        POPBasicAnimation *animation = [POPBasicAnimation easeInEaseOutAnimation];
        POPSpringAnimation *animation = [POPSpringAnimation animation];
        animation.velocity = @0.3;
        animation.property = [POPAnimatableProperty propertyWithName:kPOPShapeLayerStrokeEnd];
        animation.toValue = @(percentValue);
        animation.removedOnCompletion = NO;
        [self.finishArc pop_addAnimation:animation forKey:@"layerStrokeAnimation"];
    }
    else {
        self.finishArc.strokeEnd = percentValue;
    }
}



@end
