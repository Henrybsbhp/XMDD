//
//  ADViewController.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ADViewController.h"
#import "WebVC.h"

@interface ADViewController ()<SYPaginatorViewDelegate, SYPaginatorViewDataSource>

@end
@implementation ADViewController

+ (instancetype)vcWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                    targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
{
    ADViewController *adctrl = [[ADViewController alloc] initWithADType:type boundsWidth:width targetVC:vc mobBaseEvent:event];
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
        CGFloat height = width*360.0/1242.0;
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
            if (index > self.adList.count-1) {
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
- (void)reloadDataWithCompleted:(void(^)(ADViewController *ctrl, NSArray *ads))completed
{
    @weakify(self);
    [[[gAdMgr rac_fetchAdListByType:self.adType] deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
        
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

- (void)reloadDataForTableView:(UITableView *)tableView
{
    [self reloadDataWithCompleted:^(ADViewController *ctrl, NSArray *ads) {
        if (ads.count > 0) {
            tableView.tableHeaderView = ctrl.adView;
        }
        else {
            tableView.tableHeaderView = nil;
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
    HKAdvertisement * ad = [self.adList safetyObjectAtIndex:pageIndex];
    [imgV setImageByUrl:ad.adPic withType:ImageURLTypeMedium defImage:@"ad_default" errorImage:@"ad_default"];
    
    UITapGestureRecognizer *tap = imgV.customObject;
    @weakify(self);
    [[[tap rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        if (self.mobBaseEvent) {
            NSString * eventstr = [NSString stringWithFormat:@"%@_%d", self.mobBaseEvent, (int)pageIndex];
            [MobClick event:eventstr];
        }
        @strongify(self);
        if (ad.adLink.length > 0) {
            WebVC * vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
            vc.url = ad.adLink;
            [self.targetVC.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            WebVC * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"WebVC"];
            vc.title = @"小马达达";
            vc.url = XIAMMAWEB;
            [self.targetVC.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    
}
@end
