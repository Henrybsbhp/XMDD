//
//  CKShadowView.m
//  JTReader
//
//  Created by jiangjunchen on 13-11-15.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKShadowView.h"
@interface CKShadowView ()
@property (nonatomic, strong) UIImageView *mImageView;
@end

@implementation CKShadowView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commInitWithFrame:frame];
        // Initialization code
    }
    return self;
}

- (id)initWithShadowImage:(UIImage *)image shadowInsets:(UIEdgeInsets)insets
{
    self = [super initWithFrame:CGRectZero];
    _shadowInsets = insets;
    _shadowImage = image;
    [self commInitWithFrame:CGRectZero];
    _mImageView.image = [image resizableImageWithCapInsets:insets];
    return self;
}

- (void)commInitWithFrame:(CGRect)frame
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.clipsToBounds = YES;

    _mImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _mImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_mImageView];

    self.contentView = [[UIView alloc] initWithFrame:[self _newRectFrom:frame forInsets:_shadowInsets]];
    [self addSubview:self.contentView];
}

#pragma mark - Setter and getter
- (void)setShadowInsets:(UIEdgeInsets)shadowInsets
{
    _shadowInsets = shadowInsets;
    self.mImageView.image = [_shadowImage resizableImageWithCapInsets:shadowInsets];
    self.contentView.frame = [self _newRectFrom:self.frame forInsets:shadowInsets];
}

- (void)setShadowImage:(UIImage *)shadowImage
{
    _shadowImage = shadowImage;
    self.mImageView.image = [_shadowImage resizableImageWithCapInsets:self.shadowInsets];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.contentView.frame = [self _newRectFrom:self.frame forInsets:self.shadowInsets];
}

#pragma mark - Utilities
- (CGRect)_newRectFrom:(CGRect)rect forInsets:(UIEdgeInsets)insets
{
    CGRect newRect = CGRectMake(insets.left, insets.top, MAX(rect.size.width - insets.left - insets.right, 0),
                             MAX(rect.size.height - insets.top - insets.bottom, 0));
    return newRect;
}


#pragma mark - Override
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    self.contentView.backgroundColor = backgroundColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
