//
//  HKBigRatingView.m
//  XiaoMa
//
//  Created by jt on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKBigRatingView.h"

@implementation HKBigRatingView

- (void)awakeFromNib
{
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.imgWidth = 30;
        self.imgHeight = 30;
        self.imgSpacing = (self.frame.size.width - 30 * 5) / 4;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.imgWidth = 30;
        self.imgHeight = 30;
        self.imgSpacing = (self.frame.size.width - 30 * 5) / 4;
    }
    return  self;
}

- (void)resetImageViewFrames
{
    CGFloat width = self.frame.size.width;
    self.imgSpacing = (width - 30 * 5) / 4;
    CGFloat x = kJTRatingViewMargin;
    CGFloat y = MAX(kJTRatingViewMargin, floor((self.frame.size.height-self.imgHeight)/2));
    for (int i = 0; i < kJTRatingMaxCount; i++)
    {
        UIImageView *imgV = (UIImageView *)[self viewWithTag:kJTRatingImageBaseTag + i];
        imgV.frame = CGRectMake(x, y, self.imgWidth, self.imgHeight);
        x += self.imgWidth + self.imgSpacing;
    }
}

@end
