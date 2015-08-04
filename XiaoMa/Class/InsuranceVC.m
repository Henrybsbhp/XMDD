//
//  InsuranceVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceVC.h"
#import "XiaoMa.h"
#import "BuyInsuranceOnlineVC.h"
#import "SYPaginator.h"
#import "HKAdvertisement.h"
#import "EnquiryInsuranceVC.h"
#import "WebVC.h"
#import "InsuranceResultVC.h"

@interface InsuranceVC ()<SYPaginatorViewDataSource,SYPaginatorViewDelegate>
@property (nonatomic, strong) SYPaginatorView *adView;
@property (nonatomic, strong) NSArray *adList;
@end

@implementation InsuranceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    CKAsyncMainQueue(^{
        [self setupADView];
    });
}

- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"rp114"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"rp114"];
}

- (void)setupADView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = width*360.0/1242.0;
    SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adView.delegate = self;
    adView.dataSource = self;
    adView.pageGapWidth = 0;
    self.adView = adView;
    [self reloadAds];
    
    @weakify(self);
    RACDisposable *dis = [[gAdMgr rac_scrollTimerSignal] subscribeNext:^(id x) {
        
        @strongify(self);
        NSInteger index = adView.currentPageIndex + 1;
        if (index > self.adList.count-1) {
            index = 0;
        }
        [adView setCurrentPageIndex:index animated:YES];
    }];
    [[self rac_deallocDisposable] addDisposable:dis];
}

- (void)reloadAds
{
    [[gAdMgr rac_fetchAdListByType:AdvertisementInsurance] subscribeNext:^(NSArray *ads) {
        self.adList = ads;
        if (self.adList.count > 0) {
            self.tableView.tableHeaderView = self.adView;
            [self.adView reloadDataRemovingCurrentPage:YES];
            self.adView.currentPageIndex = 0;
            self.adView.pageControl.hidden = self.adList.count <= 1;
        }
        else {
            self.tableView.tableHeaderView = nil;
        }
    }];
}
#pragma mark - Action
- (IBAction)actionBuyInsuraceOline:(id)sender {
    [MobClick event:@"rp114-2"];
//    BuyInsuranceOnlineVC *vc = [UIStoryboard vcWithId:@"BuyInsuranceOnlineVC" inStoryboard:@"Insurance"];
//    vc.originVC = self;
//    [self.navigationController pushViewController:vc animated:YES];
    
    //支付成功失败弹出框测试，注释了爱车宝的网页页面，需要时请替换     LYW
    InsuranceResultVC *resultVC = [UIStoryboard vcWithId:@"InsuranceResultVC" inStoryboard:@"Insurance"];
    [resultVC setResultType:(arc4random() % 3)];
    [self.navigationController pushViewController:resultVC animated:YES];
}

- (IBAction)actionEnquireInsurance:(id)sender {
    [MobClick event:@"rp114-1"];
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        EnquiryInsuranceVC *vc = [UIStoryboard vcWithId:@"EnquiryInsuranceVC" inStoryboard:@"Insurance"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return self.adList.count;
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
    [[gMediaMgr rac_getPictureForUrl:ad.adPic withType:ImageURLTypeMedium defaultPic:@"ad_default" errorPic:@"ad_default"]
     subscribeNext:^(id x) {
        imgV.image = x;
    }];
    
    UITapGestureRecognizer *tap = imgV.customObject;
    @weakify(self);
    [[[tap rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        NSString * eventstr = [NSString stringWithFormat:@"rp114-3_%ld", pageIndex];
        [MobClick event:eventstr];
        @strongify(self);
        if (ad.adLink.length > 0) {
            WebVC * vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
            vc.url = ad.adLink;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    
}


@end
