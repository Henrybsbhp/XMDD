//
//  ADViewController.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ADViewController.h"
#import "NavigationModel.h"
#import "MutualInsVC.h"

@interface ADViewController ()<SYPaginatorViewDelegate, SYPaginatorViewDataSource>
@property (nonatomic, strong) NavigationModel *navModel;
@end
@implementation ADViewController

- (void)dealloc
{
    DebugLog(@"ADViewController Dealloc");
}



+ (instancetype)vcWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                    targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
                    mobBaseKey:(NSString *)mobKey
{
    ADViewController *adctrl = [[ADViewController alloc] initWithADType:type boundsWidth:width targetVC:vc mobBaseEvent:event mobBaseKey:mobKey];
    return adctrl;
}


- (instancetype)initWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                      targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
                    mobBaseKey:(NSString *)mobKey
{
    
    @weakify(self);
    self = [super init];
    if (self) {
        _targetVC = vc;
        _adType = type;
        _mobBaseEvent = event;
        _mobBaseKey = mobKey;
        _navModel = [[NavigationModel alloc] init];
        _navModel.curNavCtrl = _targetVC.navigationController;
        CGFloat height = floor(width*184.0/640);
        
        
        SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        adView.isInfinite = YES;
        adView.delegate = self;
        adView.dataSource = self;
        adView.pageGapWidth = 0;
        adView.pageControl.hidden = YES;
        _adView = adView;
        
        [adView setCurrentPageIndex:0];
        
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
- (void)reloadDataWithForce:(BOOL)force completed:(void(^)(ADViewController *ctrl, NSArray *ads))completed
{
    @weakify(self);
    RACSignal *signal = force ? [gAdMgr rac_getAdvertisement:self.adType] : [gAdMgr rac_fetchAdListByType:self.adType];
    [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
        
        @strongify(self);
        
        /// 为了制造循环滚动的效果，数据结构为：d【abcd】a，如果个数为一个的话，则忽略按照原始样子
        if (ads.count > 1)
        {
            NSMutableArray * tempArray = [NSMutableArray array];
            [tempArray safetyAddObject:[ads lastObject]];
            [tempArray safetyAddObjectsFromArray:ads];
            [tempArray safetyAddObject:[ads firstObject]];
            _adList = [NSArray arrayWithArray:tempArray];
        }
        else
        {
            _adList = ads;
        }
        
        [(SYPaginatorView *)self.adView reloadDataRemovingCurrentPage:YES];
        [(SYPaginatorView *)self.adView setCurrentPageIndex:ads.count > 1 ? 1 : 0];
        [(SYPaginatorView *)self.adView pageControl].hidden = ads.count <= 1;
        
        if (completed) {
            completed(self, ads);
        }
    }];
}

- (void)reloadDataForTableView:(UITableView *)tableView
{
    [self reloadDataWithForce:NO completed:^(ADViewController *ctrl, NSArray *ads) {
        CKAsyncMainQueue(^{
            if (ads.count > 0) {
                tableView.tableHeaderView = ctrl.adView;
            }
            else {
                UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
                header.backgroundColor = [UIColor clearColor];
                tableView.tableHeaderView = header;
            }
        });
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
    
    NSString * defaultImage = @"ad_default_2_5";
    if (self.adType == AdvertisementHomePageBottom)
    {
        defaultImage = @"hp_bottom_ad_default_340";
    }
    else if (self.adType == AdvertisementMutualInsTop)
    {
        defaultImage = @"ad_default_mutualIns_top";
    }
    [imgV setImageByUrl:ad.adPic withType:ImageURLTypeMedium defImage:defaultImage errorImage:defaultImage];
    
    UITapGestureRecognizer *tap = imgV.customObject;
    @weakify(self);
    [[[tap rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {

        @strongify(self)
        [self actionTapWithAdvertisement:ad];
    }];
    
    return pageView;
}

#pragma mark - Action

- (void)actionTapWithAdvertisement:(HKAdvertisement *)ad
{
    NSInteger pageIndex = [self.adList indexOfObject:ad];
    
    if (self.mobBaseEvent.length && self.mobBaseKey.length) {
        NSString * eventstr = [NSString stringWithFormat:@"guanggao_%d", (int)pageIndex];
        [MobClick event:self.mobBaseEvent attributes:@{self.mobBaseKey:eventstr}];
    }
    else
    {
        DebugLog(@"这个页面的广告页面mobBaseEvent,mobBaseKey为空,请务必补充");
    }
    
    if (ad.adLink.length > 0) {
        [self.navModel pushToViewControllerByUrl:ad.adLink];
    }
    else {
        if (_adType == AdvertisementHomePageBottom)
        {
            if ([LoginViewModel loginIfNeededForTargetViewController:self.targetVC])
            {
                UIViewController *vc = [UIStoryboard vcWithId:@"NewGainAwardVC" inStoryboard:@"Award"];
                [self.targetVC.navigationController pushViewController:vc animated:YES];
            }
        }
        else if (_adType != AdvertisementValuation) {
            
            DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
            vc.url = ADDEFINEWEB;
            [self.targetVC.navigationController pushViewController:vc animated:YES];
        }
        
        
    }
}

@end
