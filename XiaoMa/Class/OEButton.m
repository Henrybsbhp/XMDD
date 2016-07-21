//
//  OEButton.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/20.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "OEButton.h"
#import "OEButtonView.h"

/// 仿系统键盘默认按钮
@interface OEButton()

@property (strong, nonatomic) OEButtonView *buttonView;

@end

@implementation OEButton

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor whiteColor];
    
    if (self.state == UIControlStateHighlighted)
    {
        color = RGBCOLOR(213, 215, 216);
    }
    
    UIColor *shadow = RGBCOLOR(136, 138, 142);
    CGSize shadowOffset = CGSizeMake(0.1, 1.1);
    CGFloat shadowBlurRadius = 0;
    
    UIBezierPath *roundedRectanglePath =
    [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 1) cornerRadius:4];
    CGContextSaveGState(context);
    CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
    [color setFill];
    [roundedRectanglePath fill];
    CGContextRestoreGState(context);
    
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setNeedsDisplay];
    
    [self updateButtonPosition];
}

- (void)updateButtonPosition
{
    
    CGFloat leftPadding = CGRectGetMinX(self.frame);
    CGFloat rightPadding = CGRectGetMaxX(self.superview.frame) - CGRectGetMaxX(self.frame);
    CGFloat minimumClearance = CGRectGetWidth(self.frame) / 2 + 8;
    
    if (leftPadding >= minimumClearance && rightPadding >= minimumClearance)
    {
        self.type = OEButtonPositionInner;
    }
    else if (leftPadding > rightPadding)
    {
        self.type = OEButtonPositionLeft;
    }
    else
    {
        self.type = OEButtonPositionRight;
    }
}

- (void)showInputView
{
    [self hideInputView];
    
    self.buttonView = [[OEButtonView alloc] initWithKeyboardButton:self];
    
    [self.window addSubview:self.buttonView];
}

- (void)hideInputView
{
    [self.buttonView removeFromSuperview];
    self.buttonView = nil;
    
    [self setNeedsDisplay];
}

@end
