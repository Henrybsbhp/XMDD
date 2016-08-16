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

@interface GifActivityIndicatorView()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UIImageView *backgroundImgViewOne;
@property (strong, nonatomic) UIImageView *backgroundImgViewTwo;
@property (strong, nonatomic) UIImageView *backgroundImgViewThree;
@property (strong, nonatomic) NSArray *animationImgs;
@property (strong, nonatomic) RACDisposable *offsetDisposable;

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
        make.width.mas_equalTo(gAppMgr.deviceInfo.screenSize.width);
        make.height.mas_equalTo(120);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
    }];
    
    self.scrollView.contentSize = CGSizeMake(647 * 3, 0);
    [self.scrollView addSubview:self.backgroundImgViewOne];
    [self.scrollView addSubview:self.backgroundImgViewTwo];
    [self.scrollView addSubview:self.backgroundImgViewThree];
}

-(void)setupImgView
{
    self.imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loading_1"]];
    
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.animationImages = self.animationImgs;
    self.imgView.animationDuration = 0.3;
    [self.imgView startAnimating];
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
    self.backgroundImgViewOne.frame = CGRectMake(0, 0, 647, 100);
    
    self.backgroundImgViewTwo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"backgroundImgView"]];
    self.backgroundImgViewTwo.contentMode = UIViewContentModeScaleAspectFit;
    self.backgroundImgViewTwo.frame = CGRectMake(647, 0, 647, 100);
    
    self.backgroundImgViewThree = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"backgroundImgView"]];
    self.backgroundImgViewThree.contentMode = UIViewContentModeScaleAspectFit;
    self.backgroundImgViewThree.frame = CGRectMake(647 * 2, 0, 647, 100);
    
}

#pragma mark - Utility

-(void)startAnimating
{
    @weakify(self)
    
    self.hidden = NO;
    
    if (![self.subviews containsObject:self.backgroundImgViewOne])
    {
        [self addSubview:self.backgroundImgViewOne];
        [self addSubview:self.backgroundImgViewTwo];
        [self setupImgView];
    }
    
    
    self.offsetDisposable = [[RACSignal interval:0.02 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
     
        @strongify(self)
        
        CGPoint contentOffset = self.scrollView.contentOffset;
        
        
        if ((NSInteger)self.scrollView.contentOffset.x >= 647 * 2)
        {
            [self loadData];
        }
        else
        {
            contentOffset.x += 5;
            self.scrollView.contentOffset = contentOffset;
        }
        
    }];
}

-(void)loadData
{
    NSArray *subViews = self.scrollView.subviews;
    
    if (subViews.count != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self.scrollView addSubview:self.backgroundImgViewOne];
    [self.scrollView addSubview:self.backgroundImgViewTwo];
    [self.scrollView addSubview:self.backgroundImgViewThree];
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
}

-(void)stopAnimating
{
    self.hidden = YES;
    [self removeSubviews];
    [self.offsetDisposable dispose];
}

- (BOOL)isAnimating
{
    return self.imgView.isAnimating;
}

#pragma mark - LazyLoad

-(NSArray *)animationImgs
{
    if (!_animationImgs)
    {
        NSMutableArray *tempImgs = [[NSMutableArray alloc]init];
        NSString *imgStr = nil;
        
        for (NSInteger i = 1; i < 5; i ++)
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