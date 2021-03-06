//
//  ShopListVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopListVC.h"
#import "ShopListStore.h"
#import "ShopDetailStore.h"
#import "HKLoadingHelper.h"
#import "UILabel+MarkupExtensions.h"
#import "NSNumber+Format.h"
#import "DistanceCalcHelper.h"
#import "ShopListTitleCell.h"
#import "ShopListServiceCell.h"
#import "ShopListActionCell.h"
#import "SearchShopListVC.h"
#import "ShopDetailVC.h"
#import "NearbyShopsViewController.h"

const NSString *kCarMaintenanceShopListVCID = @"$CarMaintenanceShopListVCID";
const NSString *kCarBeautyShopListVCID = @"$CarBeautyShopListVCID";

@interface ShopListVC ()
@property (nonatomic, strong) HKLoadingHelper *loadingHelper;
@property (nonatomic, strong) ShopListStore *store;

@property (nonatomic, copy)NSString * mobClickEvent;
@end

@implementation ShopListVC

- (void)dealloc {
    
    DebugLog(@"ShopListVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackgroundColor;
    self.loadingHelper = [HKLoadingHelper loadingHelperWithPageAmount:10];
    self.store = [[ShopListStore alloc] initWithServiceType:self.serviceType];
    [self setupNavigationBar];
    [self setupTableView];
    [self actionRefresh:nil];
    
    if (self.serviceType == ShopServiceCarMaintenance)
    {
        self.mobClickEvent = @"baoyangshouye";
    }
    else if (self.serviceType == ShopServiceCarBeauty)
    {
        self.mobClickEvent = @"meirongshouye";
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.mobClickEvent.length)
    {
        [MobClick beginLogPageView:self.mobClickEvent];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.mobClickEvent.length)
    {
        [MobClick endLogPageView:self.mobClickEvent];
    }
}

#pragma mark - Setup
- (void)setupNavigationBar {
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_search_300"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(actionSearch:)];
    UIBarButtonItem *mapItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_local_300"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(actionMap:)];
    self.navigationItem.rightBarButtonItems = @[mapItem, searchItem];
    self.navigationItem.title = [ShopDetailStore serviceGroupDescForServiceType:self.serviceType];
}

- (void)setupTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[JTTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, CGFLOAT_MIN)];
    _tableView.showBottomLoadingView = YES;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[ShopListTitleCell class] forCellReuseIdentifier:@"title"];
    [_tableView registerClass:[ShopListServiceCell class] forCellReuseIdentifier:@"service"];
    [_tableView registerClass:[ShopListActionCell class] forCellReuseIdentifier:@"action"];
}


#pragma mark - Action 
- (void)actionBack:(id)sender {
    [super actionBack:sender];
    
    if (self.mobClickEvent.length)
    {
        [MobClick event:self.mobClickEvent attributes:@{@"navi":@"back"}];
    }
}

- (void)actionRefresh:(id)sender {
    [self requestShopList];
}

- (void)actionSearch:(id)sender {
    if (self.mobClickEvent.length)
    {
        [MobClick event:self.mobClickEvent attributes:@{@"navi":@"sousuo"}];
    }
    SearchShopListVC *vc = [[SearchShopListVC alloc] init];
    if (self.serviceType == ShopServiceCarWash || self.serviceType == ShopServiceCarwashWithHeart) {
        vc.serviceType = ShopServiceAllCarWash;
    }
    else {
        vc.serviceType = self.serviceType;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionMap:(id)sender {
    if (self.mobClickEvent.length)
    {
        [MobClick event:self.mobClickEvent attributes:@{@"navi":@"ditu"}];
    }
    NearbyShopsViewController * vc = [carWashStoryboard instantiateViewControllerWithIdentifier:@"NearbyShopsViewController"];
    if (self.serviceType == ShopServiceCarWash || self.serviceType == ShopServiceCarwashWithHeart) {
        vc.serviceType = ShopServiceAllCarWash;
    }
    else {
        vc.serviceType = self.serviceType;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoShopDetailWithShop:(JTShop *)shop {
    ShopDetailVC *vc = [[ShopDetailVC alloc] init];
    vc.shop = shop;
    vc.coupon = self.coupon;
    vc.serviceType = self.serviceType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionMakeCallWithPhoneNumber:(NSString *)phone {

    if (phone.length == 0) {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"好吧" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb"
                                                          Message:@"该店铺没有电话~" ActionItems:@[cancel]];
        [alert show];
    }
    else {
        [gPhoneHelper makePhone:phone andInfo:phone];
    }
    
}

- (void)actionNavigationWithShop:(JTShop *)shop {

    [gPhoneHelper navigationRedirectThirdMap:shop
                             andUserLocation:self.store.coordinate
                                     andView:self.navigationController.view];
}


#pragma mark - Datasource
- (void)reloadDatasource {
    self.loadingHelper.isRemain = YES;
    self.datasource = [CKList listWithArray:[self createCellItemsWithShops:[self.store.shopList allObjects]]];
    [self.tableView reloadData];
}

- (NSArray *)createCellItemsWithShops:(NSArray *)shops {
    return [shops arrayByMapFilteringOperator:^id(JTShop *shop) {
        return $([self titleCellWithShop:shop],
                 CKJoin([self serviceCellListWithShop:shop]),
                 [self actionCellWithShop:shop]);
    }];
}


#pragma mark - Request
- (void)requestShopList {
    @weakify(self);
    RACSignal *signal = [self.store fetchShopListByDistanceWithLocationErrorHandler:^(NSError *error) {
        
        @strongify(self);
        [self handleLocationError:error];
    }];
    
    [[signal initially:^{
      
        @strongify(self);
        [self beginRefreshIfNeeded];
    }] subscribeNext:^(id x) {
      
        @strongify(self);
        BOOL existRefresh = [self endRefreshIfNeeded];
        if (self.store.shopList.count == 0) {
            [self.view showImageEmptyViewWithImageName:@"def_withoutShop" text:@"暂无商铺" tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self requestShopList];
            }];
            return ;
        }
        if (!existRefresh) {
            self.tableView.hidden = NO;
            [self.tableView.refreshView addTarget:self action:@selector(actionRefresh:)
                                 forControlEvents:UIControlEventValueChanged];
        }
        [self reloadDatasource];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        if (![self endRefreshIfNeeded]) {
            [self.view showImageEmptyViewWithImageName:kImageFailConnect text:@"获取商铺失败，点击重试" tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self requestShopList];
            }];
        }
    }];
}

- (void)requestMoreShopList {
    @weakify(self);
    [[[self.store fetchMoreShopListByDistance] initially:^{
        
        @strongify(self);
        self.loadingHelper.isLoading = YES;
        [self.tableView.bottomLoadingView startActivityAnimation];
    }] subscribeNext:^(GetShopByDistanceV2Op *op) {
        
        @strongify(self);
        self.loadingHelper.isRemain = op.rsp_shopArray.count == self.loadingHelper.pageAmount;
        self.loadingHelper.isLoading = NO;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [self.datasource addObjectsFromArray:[self createCellItemsWithShops:op.rsp_shopArray]];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        self.loadingHelper.isLoading = NO;
        [self.tableView.bottomLoadingView stopActivityAnimation];
        [self.tableView.bottomLoadingView showIndicatorTextWith:@"加载失败，点击重试" clickBlock:^(UIButton *sender) {
            @strongify(self);
            [self.tableView.bottomLoadingView hideIndicatorText];
            [self requestMoreShopList];
        }];
    }];
}

#pragma mark - RefreshHandler
- (BOOL)beginRefreshIfNeeded {
    if ([self.tableView isRefreshViewExists]) {
        [self.tableView.refreshView beginRefreshing];
        return YES;
    }

    self.tableView.hidden = YES;
    CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
    [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
    return NO;
}

- (BOOL)endRefreshIfNeeded {
    if ([self.tableView isRefreshViewExists]) {
        [self.tableView.refreshView endRefreshing];
        return YES;
    }
    [self.view stopActivityAnimation];
    return NO;
}

- (void)handleLocationError:(NSError *)error {
    if (![self endRefreshIfNeeded]) {
        @weakify(self);
        [self.view showImageEmptyViewWithImageName:@"def_withoutShop" text:@"定位失败" tapBlock:^{
            @strongify(self);
            [self requestShopList];
        }];
    }
    
    switch (error.code) {
        case kCLErrorDenied: {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开，然后重启应用" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
            if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
                [av addButtonWithTitle:@"前往设置"];
            }
            
            [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *x) {
                NSInteger index = [x integerValue];
                if (index == 1) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }
                [self.navigationController popViewControllerAnimated:YES];
            }];
            [av show];
        };break;
        case LocationFail: {
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"城市定位失败,请重试" ActionItems:@[cancel]];
            [alert show];
            
        };break;
        default: {
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                [self.navigationController popViewControllerAnimated:YES];
            }];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"定位失败，请重试" ActionItems:@[cancel]];
            [alert show];
        }
    }
}

#pragma mark - Cell
- (CKDict *)titleCellWithShop:(JTShop *)shop {
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"title", @"shop": shop}];
    dict[@"distance"] = [DistanceCalcHelper getDistanceStrLatA:self.store.coordinate.latitude
                                                          lngA:self.store.coordinate.longitude
                                                          latB:shop.shopLatitude
                                                          lngB:shop.shopLongitude];
    double rate = [shop rateForServiceType:self.serviceType];
    dict[@"rate"] = @(rate);
    dict[@"ratestr"] = [NSString stringWithFormat:@"%@分",
                     [@(rate) decimalStringWithMaxFractionDigits:1 minFractionDigits:1]];
    dict[@"commentno"] = @([shop commentNumberForServiceType:self.serviceType]);
    
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, ShopListTitleCell *cell, NSIndexPath *indexPath) {
        
        JTShop *shop = dict[@"shop"];
        [cell.logoView setImageByUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail
                            defImage:@"cm_shop" errorImage:@"cm_shop"];
        cell.titleLabel.text = shop.shopName;
        cell.ratingView.ratingValue = [dict[@"rate"] doubleValue];
        cell.rateLabel.text = dict[@"ratestr"];
        cell.commentLabel.text = [NSString stringWithFormat:@"%@", dict[@"commentno"]];
        cell.addressLabel.text = shop.shopAddress;
        cell.distanceLabel.text = dict[@"distance"];
        cell.tipLabel.text = [shop descForBusinessStatus];
        // 休假
        if ([shop.isVacation integerValue] == 1) {
            cell.closedView.hidden = NO;
            cell.tipLabel.hidden = YES;
        }
        else {
            cell.closedView.hidden = YES;
            cell.tipLabel.hidden = NO;
            cell.tipLabel.text = [shop descForBusinessStatus];
            cell.tipLabel.backgroundColor = [shop isInBusinessHours] ? kDefTintColor : HEXCOLOR(@"#cfdbd3");
        }
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 14)];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 86;
    });
    
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        if (self.mobClickEvent.length)
        {
            [MobClick event:self.mobClickEvent attributes:@{@"shanghu":@"xinxi"}];
        }
        [self actionGotoShopDetailWithShop:data[@"shop"]];
    });
    return dict;
}

- (NSArray *)serviceCellListWithShop:(JTShop *)shop {
    NSMutableArray *result = [NSMutableArray array];
    if (self.serviceType == ShopServiceAllCarWash) {
        JTShopService *service1 = [[shop filterShopServiceByType:ShopServiceCarWash] safetyObjectAtIndex:0];
        JTShopService *service2 = [[shop filterShopServiceByType:ShopServiceCarwashWithHeart] safetyObjectAtIndex:0];
        [result safetyAddObject:[self serviceCellWithShop:shop andService:service1]];
        [result safetyAddObject:[self serviceCellWithShop:shop andService:service2]];
    }
    else {
        JTShopService *service = [[shop filterShopServiceByType:self.serviceType] safetyObjectAtIndex:0];
        [result safetyAddObject:[self serviceCellWithShop:shop andService:service]];
    }
    return result;
}

- (nullable CKDict*)serviceCellWithShop:(JTShop *)shop andService:(JTShopService *)service {
    if (!shop || !service) {
        return nil;
    }
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"service", @"shop": shop}];
    dict[@"service"] = [ShopListStore descForShopServiceWithService:service andShop:shop];
    dict[@"price"] = [ShopListStore markupForShopServicePrice:service];

    @weakify(self);
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, ShopListServiceCell *cell, NSIndexPath *indexPath) {
        
        cell.serviceLabel.text = dict[@"service"];
        [cell.priceLabel setMarkup:dict[@"price"]];
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 14)];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        
        if (self.mobClickEvent.length)
        {
            [MobClick event:self.mobClickEvent attributes:@{@"fuwu":@"fuwu"}];
        }
        [self actionGotoShopDetailWithShop:data[@"shop"]];
    });

    return dict;
}

- (CKDict *)actionCellWithShop:(JTShop *)shop {
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"action", @"shop": shop}];
    
    @weakify(self);
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, ShopListActionCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        [[[cell.navigationButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            if (self.mobClickEvent.length)
            {
                [MobClick event:self.mobClickEvent attributes:@{@"shanghu":@"daohang"}];
            }
            [self actionNavigationWithShop:data[@"shop"]];
        }];
        
        [[[cell.phoneButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            JTShop *shop = data[@"shop"];
            
            if (self.mobClickEvent.length)
            {
                [MobClick event:self.mobClickEvent attributes:@{@"shanghu":@"dianhua"}];
            }
            [self actionMakeCallWithPhoneNumber:shop.shopPhone];
        }];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    dict[kCKCellWillDisplay] = CKCellWillDisplay(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        // 上拉加载
        if ([self.loadingHelper canLoadMoreForDatasource:self.datasource atRow:indexPath.section]) {
            [self requestMoreShopList];
        }
    });
    return dict;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}


@end
