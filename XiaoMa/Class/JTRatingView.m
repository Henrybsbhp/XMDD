//
//  JTRatingView.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-31.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "JTRatingView.h"
#import <ReactiveCocoa.h>
#import <CKKit.h>

#define kJTNormalRatingImage    @"nb_star"
#define kJTHighlightRatingImage @"nb_star1"
#define kJTHalfRatingImage      @"nb_start2"
#define kJTRatingViewMargin     0
#define kJTRatingMaxCount       5
#define kJTRatingImageBaseTag   100000

@interface JTRatingView ()
@property (nonatomic, strong) RACSubject *rac_subject;
@end
@implementation JTRatingView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commInit];
        [self resetImageViewFrames];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commInit];
        [self resetImageViewFrames];
    }
    return  self;
}

- (void)commInit
{
    _imgWidth = 13;
    _imgHeight = 12;
    _imgSpacing = 3;
    _normalImageName = kJTNormalRatingImage;
    _highlightImageName = kJTHighlightRatingImage;
    for (int i = 0; i < kJTRatingMaxCount; i++)
    {
        UIImageView *imgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_normalImageName]];
        imgV.tag = kJTRatingImageBaseTag + i;
        [self addSubview:imgV];
    }
}

- (void)resetImageViewFrames
{
    CGFloat x = kJTRatingViewMargin;
    CGFloat y = MAX(kJTRatingViewMargin, floor((self.frame.size.height-_imgHeight)/2));
    for (int i = 0; i < kJTRatingMaxCount; i++)
    {
        UIImageView *imgV = (UIImageView *)[self viewWithTag:kJTRatingImageBaseTag + i];
        imgV.frame = CGRectMake(x, y, _imgWidth, _imgHeight);
        x += _imgWidth + _imgSpacing;
    }
}

- (void)sizeToFit
{
    CGFloat width = _imgWidth*kJTRatingMaxCount + MAX(0, kJTRatingMaxCount-1)*_imgSpacing;
    CGFloat height = _imgHeight;
    CGRect frame = self.frame;
    frame.size = CGSizeMake(width, height);
    self.frame = frame;
}

- (void)setRatingValue:(CGFloat)ratingValue
{
    ratingValue = MAX(0, MIN(kJTRatingMaxCount, ratingValue));
    if (_ratingValue == ratingValue)
    {
        return;
    }
    _ratingValue = ratingValue;
    int v = CKRoundto(ratingValue);
    for (int i = 0; i < kJTRatingMaxCount; i++)
    {
        UIImageView *imgV = (UIImageView *)[self viewWithTag:kJTRatingImageBaseTag + i];
        if (i >= v)
        {
            imgV.image = [UIImage imageNamed:_normalImageName];
        }
        else
        {
            imgV.image = [UIImage imageNamed:_highlightImageName];
        }
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //暂时只在底层这里找到可以发送到友盟的事件
    [MobClick event:@"rp321-1"];
    [self touchesMoved:touches withEvent:event];
}

//鼠标移动后，判断鼠标点的距离，从而设置星星的样式
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt = [[touches anyObject] locationInView:self];
    CGFloat value = (pt.x - kJTRatingViewMargin + _imgSpacing) / (_imgSpacing + _imgWidth);
    [self setRatingValue:value];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self resetImageViewFrames];
}

@end
