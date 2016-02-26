//
//  SuspendedAdVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/2/24.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "SuspendedAdVC.h"
#import "NavigationModel.h"

@interface SuspendedAdVC ()<SYPaginatorViewDelegate, SYPaginatorViewDataSource>

@property (nonatomic, strong) NavigationModel *navModel;

@end

@implementation SuspendedAdVC

+ (instancetype)vcWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
{
    SuspendedAdVC *adctrl = [[SuspendedAdVC alloc] initWithADType:type boundsWidth:width targetVC:vc mobBaseEvent:event];
    return adctrl;
}

- (instancetype)initWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                      targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
{
    self = [super init];
    if (self) {
        _targetVC = vc;
        _adType = type;
        _mobBaseEvent = event;
        _navModel = [[NavigationModel alloc] init];
        _navModel.curNavCtrl = _targetVC.navigationController;
        CGFloat height = floor(width * 800 / 600);
        SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        adView.delegate = self;
        adView.dataSource = self;
        adView.pageGapWidth = 0;
        adView.pageControl.hidden = YES;
        _adView = adView;
        
        [adView setCurrentPageIndex:0];
        @weakify(self);
        RACDisposable *dis = [[gAdMgr rac_scrollTimerSignal] subscribeNext:^(id x) {
            
            @strongify(self);
            NSInteger index = adView.currentPageIndex + 1;
            if (index > (int)(self.adList.count)-1) {
                index = 0;
            }
            if (index != adView.currentPageIndex) {
                [adView setCurrentPageIndex:index animated:YES];
            }
        }];
        [[self rac_deallocDisposable] addDisposable:dis];
    }
    return self;
}

#pragma mark - Reload
- (void)reloadDataWithForce:(BOOL)force completed:(void(^)(SuspendedAdVC *ctrl, NSArray *ads))completed
{
    
    @weakify(self);
    RACSignal *signal = force ? [gAdMgr rac_getAdvertisement:self.adType] : [gAdMgr rac_fetchAdListByType:self.adType];
    [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
        
        @strongify(self);
        _adList = ads;
        [self.adView reloadDataRemovingCurrentPage:YES];
        self.adView.currentPageIndex = 0;
        self.adView.pageControl.hidden = self.adList.count <= 1;
        if (completed) {
            completed(self, ads);
        }
    }];
}

#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return self.adList.count > 0 ? self.adList.count : 1;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SYPageView *pageView = [paginatorView dequeueReusablePageWithIdentifier:@"pageView"];
    
    if (!pageView) {
        pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:pageView.bounds];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        imgV.tag = 1001;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [imgV addGestureRecognizer:tap];
        imgV.userInteractionEnabled = YES;
        imgV.customObject = tap;
        
        [pageView addSubview:imgV];
    }
    
    UIImageView *imgV = (UIImageView *)[pageView viewWithTag:1001];
    
    UIActivityIndicatorView * activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(pageView.frame.size.width / 2 - 10, pageView.frame.size.height / 2 + 10, 20, 20)];
    [activityView startAnimating];
    
    [imgV addSubview:activityView];
    HKAdvertisement * ad = [self.adList safetyObjectAtIndex:pageIndex];
    
    NSURL * adUrl = ad.adPic ? [NSURL URLWithString:ad.adPic] : nil;
    __weak UIImageView *weakView = imgV;
    [imgV sd_setImageWithURL:adUrl placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        [activityView stopAnimating];
        if (!weakView) {
            return ;
        }
    }];
    
    UITapGestureRecognizer *tap = imgV.customObject;
    @weakify(self);
    [[[tap rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        if ([self.clickDelegate respondsToSelector:@selector(adClick)]) {
            [self.clickDelegate adClick];
            if (self.mobBaseEvent.length != 0) {
                NSString * eventstr = [NSString stringWithFormat:@"%@_%d", self.mobBaseEvent, (int)pageIndex];
                [MobClick event:eventstr];
            }
            @strongify(self);
            if (ad.adLink.length > 0) {
                [self.navModel pushToViewControllerByUrl:ad.adLink];
            }
            else {
                if (_adType != AdvertisementValuation) {
                    
                    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
                    vc.url = ADDEFINEWEB;
                    [self.targetVC.navigationController pushViewController:vc animated:YES];
                }
            }
        }
    }];
    
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    
}

@end
