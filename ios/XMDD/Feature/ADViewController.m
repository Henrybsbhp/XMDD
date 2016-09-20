//
//  ADViewController.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "ADViewController.h"
#import "NavigationModel.h"
#import "HKScrollDisplayVC.h"
#import "MutualInsVC.h"

@interface ADViewController ()<SYPaginatorViewDelegate, SYPaginatorViewDataSource, HKScrollDisplayVCDelegate>
@property (nonatomic, strong) NavigationModel *navModel;
@property (strong, nonatomic) HKScrollDisplayVC *sdVC;
@end
@implementation ADViewController

+ (instancetype)vcWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                    targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
            mobBaseEventDict:(NSDictionary *)dict
{
    ADViewController *adctrl = [[ADViewController alloc] initWithADType:type boundsWidth:width targetVC:vc mobBaseEvent:event mobBaseEventDict:dict];
    return adctrl;
}

+ (instancetype)vcWithMutualADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                          targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event
                  mobBaseEventDict:(NSDictionary *)dict
{
    ADViewController *adctrl = [[ADViewController alloc] initWithMutualADType:type boundsWidth:width targetVC:vc mobBaseEvent:event mobBaseEventDict:dict];
    return adctrl;
}

- (instancetype)initWithADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                      targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event mobBaseEventDict:(NSDictionary *)dict
{
    
    @weakify(self);
    self = [super init];
    if (self) {
        _targetVC = vc;
        _adType = type;
        _mobBaseEvent = event;
        _mobBaseEventDict = dict;
        _navModel = [[NavigationModel alloc] init];
        _navModel.curNavCtrl = _targetVC.navigationController;
        CGFloat height = floor(width*184.0/640);
        
        if (type == AdvertisementHomePage)
        {
            self.sdVC = [[HKScrollDisplayVC alloc] initWithAdLists:self.adList];
            self.sdVC.delegate = self;
            [_targetVC addChildViewController:self.sdVC];
            self.sdVC.view.frame = CGRectMake(0, 0, width, height);
            self.sdVC.currentPage = 0;
            _adView = self.sdVC.view;
            RACDisposable *dis = [[gAdMgr rac_scrollTimerSignal] subscribeNext:^(id x) {
                
                @strongify(self);
                self.sdVC.currentPage ++;
                
            }];
            [[self rac_deallocDisposable] addDisposable:dis];
        }
        else
        {
            
            SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
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
    }
    return self;
}

- (instancetype)initWithMutualADType:(AdvertisementType)type boundsWidth:(CGFloat)width
                            targetVC:(UIViewController *)vc mobBaseEvent:(NSString *)event mobBaseEventDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _targetVC = vc;
        _adType = type;
        _mobBaseEvent = event;
        _mobBaseEventDict = dict;
        _navModel = [[NavigationModel alloc] init];
        _navModel.curNavCtrl = _targetVC.navigationController;
        CGFloat height = floor(width/4.15);
        
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
- (void)reloadDataWithForce:(BOOL)force completed:(void(^)(ADViewController *ctrl, NSArray *ads))completed
{
    @weakify(self);
    RACSignal *signal = force ? [gAdMgr rac_getAdvertisement:self.adType] : [gAdMgr rac_fetchAdListByType:self.adType];
    [[signal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSArray *ads) {
        
        @strongify(self);
        _adList = ads;
        if (self.adType == AdvertisementHomePage)
        {
            self.sdVC.adList = ads;
        }
        else
        {
            [(SYPaginatorView *)self.adView reloadDataRemovingCurrentPage:YES];
            [(SYPaginatorView *)self.adView setCurrentPageIndex:0];
            [(SYPaginatorView *)self.adView pageControl].hidden = self.adList.count <= 1;
        }
        
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

#pragma mark - HKScrollDisplayVCDelegate

- (void)scrollDisplayViewController:(HKScrollDisplayVC *)scrollDisplayViewController didSelectedIndex:(NSInteger)index
{
    [self actionTapWithAdvertisement:[self.adList safetyObjectAtIndex:index]];
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

-(void)actionTapWithAdvertisement:(HKAdvertisement *)ad
{
    NSInteger pageIndex = [self.adList indexOfObject:ad];
    
    if (self.mobBaseEventDict)
    {
        NSString * key = [self.mobBaseEventDict.allKeys safetyObjectAtIndex:0];
        NSString * value = [self.mobBaseEventDict objectForKey:key];
        NSString * valueWithIndex = [NSString stringWithFormat:@"%@_%d", value, (int)pageIndex];
        [MobClick event:self.mobBaseEvent attributes:@{key:valueWithIndex}];
    }
    else if (self.mobBaseEvent.length) {
        NSString * eventstr = [NSString stringWithFormat:@"%@_%d", self.mobBaseEvent, (int)pageIndex];
        [MobClick event:eventstr];
    }
    
    if (ad.adLink.length > 0) {
        [self.navModel pushToViewControllerByUrl:ad.adLink];
    }
    else {
        if (_adType == AdvertisementHomePageBottom)
        {
            if (![LoginViewModel loginIfNeededForTargetViewController:self.targetVC.navigationController])
            {
                UIViewController *vc = [UIStoryboard vcWithId:@"NewGainAwardVC" inStoryboard:@"Award"];
                [self.targetVC.navigationController pushViewController:vc animated:YES];
            }
        }
        else if (_adType == AdvertisementMutualInsTop)
        {
            if ([gAppMgr.navModel.curNavCtrl.topViewController isKindOfClass:[MutualInsVC class]])
            {
                MutualInsVC * vc = (MutualInsVC *)gAppMgr.navModel.curNavCtrl.topViewController;
                [vc presentAdPageVC];
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
