//
//  InsCouponView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/10.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsCouponView.h"
#import "UIView+RoundedCorner.h"

#define HorizontalSpacing   26
#define VerticalSpacing     8

@interface InsCouponView ()
@property (nonatomic, strong) NSMutableArray *buttons;
@end

@implementation InsCouponView

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
    _buttonHeight = 25;
    _buttonTitleColor = kGrayTextColor;
    _buttonBorderColor = HEXCOLOR(@"#E3E3E3");
    [self setup];
}

- (void)setup
{
    if (self.buttons) {
        [self.buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    self.buttons = [NSMutableArray array];
}

+ (CGFloat)heightWithCouponCount:(NSUInteger)count buttonHeight:(CGFloat)height
{
    NSInteger rows = ceil(count / 2.0);
    return rows * (height+VerticalSpacing) + VerticalSpacing;
}

- (void)setCoupons:(NSArray *)coupons
{
    _coupons = coupons;
    if (self.buttons.count > coupons.count) {
        NSInteger tail = MAX(coupons.count-1, 0);
        for (NSInteger i = tail; i < self.buttons.count; i++) {
            [self.buttons[i] removeFromSuperview];
        }
        [self.buttons safetyRemoveObjectsFromIndex:tail];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    for (NSInteger i = 0; i < self.coupons.count; i++) {
        NSString *title = [self.coupons safetyObjectAtIndex:i];
        UIButton *btn = [self.buttons safetyObjectAtIndex:i];
        if (!btn) {
            btn = [self createBaseButton];
            [self.buttons addObject:btn];
            [self addSubview:btn];
        }
        btn.customObject = title;
        [btn setTitle:title forState:UIControlStateNormal];
        CGFloat width = ceil((self.frame.size.width - 3 * HorizontalSpacing) / 2.0);
        CGFloat x = (i%2)*(HorizontalSpacing+width)+HorizontalSpacing;
        CGFloat y = (i/2)*(VerticalSpacing+self.buttonHeight)+VerticalSpacing;
        btn.frame = CGRectMake(x, y, width, self.buttonHeight);
    }
}

- (UIButton *)createBaseButton
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectZero];
    btn.titleLabel.font = [UIFont systemFontOfSize:14];
    [btn setTitleColor:self.buttonTitleColor forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    [btn setCornerRadius:self.buttonHeight / 2.0 withBorderColor:self.buttonBorderColor borderWidth:0.5
         backgroundColor:[UIColor whiteColor] backgroundImage:nil contentMode:UIViewContentModeScaleToFill];
//    btn.layer.cornerRadius = self.buttonHeight / 2.0;
//    btn.layer.borderWidth  = 0.5;
//    btn.layer.borderColor = [self.buttonBorderColor CGColor];
//    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(actionClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)actionClick:(UIButton *)sender
{
    if (self.buttonClickBlock) {
        self.buttonClickBlock(sender.customObject);
    }
}
@end
