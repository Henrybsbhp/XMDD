//
//  GifActivityIndicatorView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/6/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//


#import "GifActivityIndicatorView.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <RACScheduler.h>

#define kBackgroundImageWidth    647

@interface GifActivityIndicatorView()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIImageView *backgroundImgViewOne;
@property (strong, nonatomic) UIImageView *backgroundImgViewTwo;
@property (strong, nonatomic) NSArray *animationImgs;

@end

@implementation GifActivityIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame])
    {
        [self setupBackgroundImgView];
        [self setupScrollView];
        [self setupImgView];
    }
    return self;
}

-(void)dealloc
{
}

#pragma mark - setup

- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.userInteractionEnabled = NO;
    [self addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(ScreenWidth);
        make.height.mas_equalTo(120);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    self.scrollView.contentSize = CGSizeMake(kBackgroundImageWidth * 2, 0);
    [self.scrollView addSubview:self.backgroundImgViewOne];
    [self.scrollView addSubview:self.backgroundImgViewTwo];
    
    CGRect bounds = CGRectMake(0, 0, ScreenWidth, 120);
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    animation.removedOnCompletion = NO;
    animation.repeatCount = HUGE_VALF;
    animation.duration = 2.6;
    animation.fromValue = [NSValue valueWithCGRect:bounds];
    bounds.origin.x = kBackgroundImageWidth;
    animation.toValue = [NSValue valueWithCGRect:bounds];
    [self.scrollView.layer addAnimation:animation forKey:@"contentOffsetAnimation"];
    [self pauseLayer:self.scrollView.layer];
}

-(void)setupImgView
{
    self.imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loading_1"]];
    
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.animationImages = self.animationImgs;
    self.imgView.animationDuration = 0.3;
    [self addSubview:self.imgView];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.centerX.mas_equalTo(-30);
        make.width.mas_equalTo(133);
        make.height.mas_equalTo(60);
    }];
}

-(void)setupBackgroundImgView
{
    self.backgroundImgViewOne = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"backgroundImgView"]];
    self.backgroundImgViewOne.contentMode = UIViewContentModeScaleAspectFit;
    self.backgroundImgViewOne.frame = CGRectMake(0, 0, kBackgroundImageWidth, 100);
    
    self.backgroundImgViewTwo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"backgroundImgView"]];
    self.backgroundImgViewTwo.contentMode = UIViewContentModeScaleAspectFit;
    self.backgroundImgViewTwo.frame = CGRectMake(647, 0, kBackgroundImageWidth, 100);
}


#pragma mark - Public
-(void)startAnimating
{
    self.hidden = NO;
    [self.imgView startAnimating];
    [self resumeLayer:self.scrollView.layer];
}


-(void)stopAnimating
{
    self.hidden = YES;
    [self.imgView stopAnimating];
    [self pauseLayer:self.scrollView.layer];
}

- (BOOL)isAnimating
{
    return self.imgView.isAnimating;
}


#pragma mark - Utility

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

#pragma mark - LazyLoad

-(NSArray *)animationImgs
{
    if (!_animationImgs)
    {
        NSMutableArray *tempImgs = [[NSMutableArray alloc]init];
        NSString *imgStr = nil;
        
        for (long i = 1; i < 5; i ++)
        {
            imgStr = [NSString stringWithFormat:@"loading_%ld",i];
            UIImage *img = [UIImage imageNamed:imgStr];
            [tempImgs addObject:img];
        }
        _animationImgs = [NSArray arrayWithArray:tempImgs];
    }
    return _animationImgs;
}



@end
