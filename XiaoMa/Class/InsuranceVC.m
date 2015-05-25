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
#import "WebVC.h"

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    [[gAdMgr rac_scrollTimerSignal] subscribeNext:^(id x) {
        NSInteger index = adView.currentPageIndex + 1;
        if (index > self.adList.count-1) {
            index = 0;
        }
        adView.currentPageIndex = index;
    }];
}

- (void)reloadAds
{
    [[gAdMgr rac_fetchAdListByType:AdvertisementInsurance] subscribeNext:^(NSArray *ads) {
        self.adList = ads;
        if (self.adList.count > 0) {
            self.tableView.tableHeaderView = self.adView;
            [self.adView reloadDataRemovingCurrentPage:YES];
            self.adView.currentPageIndex = 0;
        }
        else {
            self.tableView.tableHeaderView = nil;
        }
    }];
}
#pragma mark - Action
- (IBAction)actionBuyInsuraceOline:(id)sender {
    BuyInsuranceOnlineVC *vc = [UIStoryboard vcWithId:@"BuyInsuranceOnlineVC" inStoryboard:@"Insurance"];
    vc.originVC = self;
    [self.navigationController pushViewController:vc animated:YES];
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
    [[gMediaMgr rac_getPictureForUrl:ad.adPic withDefaultPic:@"hp_bottom"] subscribeNext:^(id x) {
        imgV.image = x;
    }];
    
    UITapGestureRecognizer *tap = imgV.customObject;
    [[[tap rac_gestureSignal] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        if (ad.adLink.length > 0) {
            WebVC * vc = [UIStoryboard vcWithId:@"WebVC" inStoryboard:@"Common"];
            vc.title = @"广告";
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
