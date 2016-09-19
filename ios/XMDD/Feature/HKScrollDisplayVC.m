//
//  HKScrollDisplayVC.m
//  XMDD
//
//  Created by RockyYe on 16/9/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKScrollDisplayVC.h"
#import "HKAdvertisement.h"

#define kDefaultImage @"ad_default_2_5"

@interface HKScrollDisplayVC ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@end

@implementation HKScrollDisplayVC

//传入图片名字数组
- (instancetype)initWithAdLists:(NSArray *)adLists
{
    if (self = [super init])
    {
        [self setupControllersWithAds:adLists];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupPageVC];
    [self setupPageControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Setup

-(void)setupPageControl
{
    self.pageControl = [UIPageControl new];
    self.pageControl.numberOfPages = self.controllers.count;
    [self.view addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(10);
    }];
    self.pageControl.userInteractionEnabled = NO;
}

-(void)setupPageVC
{
    self.pageVC = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageVC.delegate = self;
    self.pageVC.dataSource = self;
    [self addChildViewController:self.pageVC];
    [self.view addSubview:self.pageVC.view];
    [self.pageVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    [self.pageVC setViewControllers:@[self.controllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

-(void)setupControllersWithAds:(NSArray *)adLists
{
    @weakify(self)
    [self.controllers removeAllObjects];
    
    NSInteger count = adLists.count == 0 ? 1 : adLists.count;
    
    for (int i = 0; i < count; i ++)
    {
        HKAdvertisement * ad = [adLists safetyObjectAtIndex:i];
        UIImageView *imgV = [[UIImageView alloc]
                             initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, floor(gAppMgr.deviceInfo.screenSize.width*184.0/640))];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        [imgV setImageByUrl:ad.adPic withType:ImageURLTypeMedium defImage:kDefaultImage errorImage:kDefaultImage];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
        [imgV addGestureRecognizer:tap];
        imgV.userInteractionEnabled = YES;
        [[tap rac_gestureSignal]subscribeNext:^(id x) {
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(scrollDisplayViewController:didSelectedIndex:)])
            {
                [self.delegate scrollDisplayViewController:self didSelectedIndex:i];
            }
        }];
        
        UIViewController *vc = [UIViewController new];
        vc.view = imgV;
        [self.controllers addObject:vc];
    }
}

#pragma mark - Set

-(void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage == currentPage)
    {
        return;
    }
    
    if (currentPage == self.controllers.count)
    {
        currentPage = 0;
    }
    
    _currentPage = currentPage;
    UIViewController *vc = [self.controllers safetyObjectAtIndex:currentPage];
    [self.pageVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self configPageControl];
    
}

-(void)setAdList:(NSArray *)adList
{
    _adList = adList;
    [self setupControllersWithAds:adList];
    [self.pageControl setNumberOfPages:self.controllers.count];
    [self.pageVC setViewControllers:@[self.controllers.firstObject] direction:0 animated:YES completion:nil];
    
}

#pragma mark - Utility

/// 操作圆点位置
- (void)configPageControl
{
    NSInteger index = [self.controllers indexOfObject:self.pageVC.viewControllers.firstObject];
    _currentPage = index;
    self.pageControl.currentPage = index;
}


#pragma mark - UIPageViewController

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (completed && finished)
    {
        [self configPageControl];
        NSInteger index = [self.controllers indexOfObject: pageViewController.viewControllers.firstObject];
        if ([self.delegate respondsToSelector:@selector(scrollDisplayViewController:currentIndex:)] )
        {
            [self.delegate scrollDisplayViewController:self currentIndex:index];
        }
        
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index=[self.controllers indexOfObject:viewController];
    if (index == 0)
    {
        return self.controllers.lastObject;
    }
    return [self.controllers safetyObjectAtIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index=[self.controllers indexOfObject:viewController];
    if (index == self.controllers.count -1)
    {
        return self.controllers.firstObject;
    }
    return [self.controllers safetyObjectAtIndex:index + 1];
}

#pragma mark - LazyLoad

-(NSMutableArray *)controllers
{
    if (!_controllers)
    {
        _controllers = [[NSMutableArray alloc]init];
    }
    return _controllers;
}


@end
