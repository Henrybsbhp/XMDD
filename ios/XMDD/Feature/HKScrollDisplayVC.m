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

/// 控制自动滚动
@property (nonatomic)BOOL canAutoScrolling;
/// 控制手动滚动
@property (nonatomic)BOOL canManualScrolling;

@end

@implementation HKScrollDisplayVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.canAutoScrolling = YES;
    self.canManualScrolling = YES;
    
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
    
    [RACObserve(self, adList) subscribeNext:^(NSArray * adList) {
        
        self.pageControl.hidden = adList.count <= 1;
    }];
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
}

-(void)setupControllersWithAds:(NSArray *)adLists
{
    @weakify(self)
    [self.controllers removeAllObjects];
    
    for (int i = 0; i < adLists.count; i ++)
    {
        HKAdvertisement * ad = [adLists safetyObjectAtIndex:i];
        UIImageView *imgV = [[UIImageView alloc]
                             initWithFrame:CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width, floor(gAppMgr.deviceInfo.screenSize.width*184.0/640))];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        
        NSString * defaultImage = kDefaultImage;
        if (self.adType == AdvertisementHomePageBottom)
        {
            defaultImage = @"hp_bottom_ad_default_340";
        }
        else if (self.adType == AdvertisementMutualInsTop)
        {
            defaultImage = @"ad_default_mutualIns_top";
        }
        [imgV setImageByUrl:ad.adPic withType:ImageURLTypeMedium defImage:defaultImage errorImage:defaultImage];
        
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
// 自动滚动
- (void)setCurrentPage:(NSInteger)currentPage
{
    if (_currentPage == currentPage || self.controllers.count <= 1)
    {
        return;
    }
    
    currentPage = currentPage >= self.controllers.count ? 0 : currentPage;
    _currentPage = currentPage;
    UIViewController *vc = [self.controllers safetyObjectAtIndex:currentPage];
    
    if (vc && self.canAutoScrolling)
    {
        __weak HKScrollDisplayVC *blockSafeSelf = self;
        
        self.pageVC.view.userInteractionEnabled = NO;
        self.canManualScrolling = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pageVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
                
                if(finished)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [blockSafeSelf.pageVC setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
                    });
                    blockSafeSelf.pageVC.view.userInteractionEnabled = YES;
                    blockSafeSelf.canManualScrolling = YES;
                }
            }];
            [self configPageControl];
        });
    }
}

- (void)setAdList:(NSArray *)adList
{
    _adList = adList;
    
    NSArray * adArray = adList;
    if (!adArray.count)
    {
        HKAdvertisement * advertisement = [[HKAdvertisement alloc] init];
        adArray = @[advertisement];
    }
    
    [self setupControllersWithAds:adArray];
    [self.pageControl setNumberOfPages:adArray.count];
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
// 手动滚动的回调
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    self.canAutoScrolling = NO;
}

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
    
    self.canAutoScrolling = YES;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (self.controllers.count < 2)
    {
        return nil;
    }
    NSInteger index=[self.controllers indexOfObject:viewController];
    UIViewController * vc;
    vc = index == 0 ? self.controllers.lastObject : [self.controllers safetyObjectAtIndex:index - 1];
    return vc;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (self.controllers.count < 2)
    {
        return nil;
    }
    NSInteger index=[self.controllers indexOfObject:viewController];
    UIViewController * vc;
    vc = index == self.controllers.count - 1 ? self.controllers.firstObject : [self.controllers safetyObjectAtIndex:index + 1];
    return vc;
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
