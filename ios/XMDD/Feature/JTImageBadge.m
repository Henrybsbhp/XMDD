//
//  JTCommentBadge.m
//  JTReader
//
//  Created by jiangjunchen on 14-2-24.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTImageBadge.h"
#import "NSString+RectSize.h"
//#define kJTCommentBadgeLeftMargin    4
//#define kJTCommentBadgeRightMargin   10
//#define kJTCommentBadgeHeightMargin   0
#define kJTCommentBadgeDefaultFont      [UIFont systemFontOfSize:12]
#define kJTCommentBadgeDefaultCorner    3

@implementation JTImageBadge

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = NO;
        self.textInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        // Initialization code
//        self.layer.cornerRadius = kJTCommentBadgeDefaultCorner;
//        self.layer.masksToBounds = YES;
        
        _backgroundView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView];

        _textFont = kJTCommentBadgeDefaultFont;

        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.font = kJTCommentBadgeDefaultFont;
        _textLabel.textAlignment = UITextAlignmentCenter;
        _textLabel.textColor = [UIColor whiteColor];
//        _textLabel.shadowColor = [UIColor darkGrayColor];
//        _textLabel.shadowOffset = CGSizeMake(0, 1);
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = _cornerRadius;
}

+ (instancetype)badgeWithText:(NSString *)text
{
    return [[self alloc] initWithText:text font:kJTCommentBadgeDefaultFont];
}

- (id)initWithText:(NSString *)text font:(UIFont *)font
{
    self = [self initWithFrame:CGRectZero];
    if (self)
    {
        [self refreshViewByText:text font:font];
    }
    return self;
}

#pragma mark - setter
- (void)setText:(NSString *)aText
{
    _text = aText;
    [self refreshViewByText:aText font:_textFont];
}

- (void)setTextFont:(UIFont *)aFont
{
    _textFont = aFont;
    [self refreshViewByText:_text font:aFont];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    self.backgroundView.highlighted = highlighted;
}

- (void)refreshViewByText:(NSString *)aText font:(UIFont *)font
{
    CGPoint center = self.center;
    if (aText.length == 0)
    {
        self.frame = CGRectZero;
    }
    else
    {
        CGSize fitSize = [aText labelSizeWithWidth:80 font:font];
        CGRect fitRect = CGRectMake(0, 0, fitSize.width + self.textInsets.left + self.textInsets.right,
                                    fitSize.height + self.textInsets.top + self.textInsets.bottom);
        self.frame = fitRect;
        _textLabel.frame = CGRectMake(self.textInsets.left, self.textInsets.top,
                                      fitSize.width, fitSize.height);
        _textLabel.text = aText;
        _textLabel.font = font;
    }

    self.center = center;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self setHighlighted:NO];
}
@end
