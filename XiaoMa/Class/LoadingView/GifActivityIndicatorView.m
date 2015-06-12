//
//  GifActivityIndicatorView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GifActivityIndicatorView.h"

@interface GifActivityIndicatorView ()
@property (nonatomic, strong) UIImageView *imgView;
@end

@implementation GifActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.imgView];
        NSMutableArray *imgs = [NSMutableArray array];
        for (int i = 1; i <= 24; i++) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"ld_%d", i]];
            [imgs addObject:img];
        }
        self.imgView.animationImages = imgs;
    }
    return self;
}

- (void)stopAnimating
{
    if (!self.hidden) {
        [self setHidden:YES animated:YES];
    }
    [self.imgView stopAnimating];
}

- (void)startAnimating
{
    if (self.hidden) {
        [self setHidden:NO animated:YES];
    }
    [self.imgView startAnimating];
}


@end
