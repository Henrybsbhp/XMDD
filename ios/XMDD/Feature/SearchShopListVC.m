//
//  SearchShopListVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "SearchShopListVC.h"
#import "ShopListStore.h"
#import "ShopDetailStore.h"
#import "HKLoadingHelper.h"
#import "UILabel+MarkupExtensions.h"
#import "NSNumber+Format.h"
#import "DistanceCalcHelper.h"
#import "JTTableView.h"
#import "SearchShopListBar.h"
#import "ShopListTitleCell.h"
#import "ShopListServiceCell.h"
#import "ShopListActionCell.h"
#import "HKTableTextCell.h"
#import "ShopDetailViewController.h"

@interface SearchShopListVC ()<UISearchBarDelegate>
@property (nonatomic, strong) SearchShopListBar *searchView;
@property (nonatomic, strong) JTTableView *tableView;
@property (nonatomic, strong) HKLoadingHelper *loadingHelper;
@property (nonatomic, strong) ShopListStore *store;
@property (nonatomic, strong) NSMutableArray *searchReacords;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isSearching;
@end
@implementation SearchShopListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackgroundColor;
    self.isEditing = YES;
    self.loadingHelper = [HKLoadingHelper loadingHelperWithPageAmount:10];
    self.store = [[ShopListStore alloc] initWithServiceType:self.serviceType];
    [self setupSearchBar];
    [self setupTableView];
    [self loadHistoryRecords];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [self.navigationController.navigationBar addSubview:self.searchView];
    if (self.isEditing) {
        [self.searchView.searchBar becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.searchView removeFromSuperview];
    self.isEditing = self.searchView.searchBar.isFirstResponder;
}

#pragma mark - Setup
- (void)setupSearchBar {
    _searchView = [[SearchShopListBar alloc] initWithFrame:CGRectMake(45, 4, ScreenWidth-45, 36)];
    _searchView.searchBar.delegate = self;
    [_searchView.searchButton addTarget:self action:@selector(actionSearch) forControlEvents:UIControlEventTouchUpInside];
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
    
    [_tableView registerClass:[HKTableTextCell class] forCellReuseIdentifier:@"historyHeader"];
    [_tableView registerClass:[HKTableTextCell class] forCellReuseIdentifier:@"historyRecord"];
    [_tableView registerClass:[HKTableTextCell class] forCellReuseIdentifier:@"historyBottom"];
    [_tableView registerClass:[ShopListTitleCell class] forCellReuseIdentifier:@"title"];
    [_tableView registerClass:[ShopListServiceCell class] forCellReuseIdentifier:@"service"];
    [_tableView registerClass:[ShopListActionCell class] forCellReuseIdentifier:@"action"];
}
#pragma mark - Datasource
- (void)reloadDatasourceWithShops:(NSArray *)shops {
    [self.view hideDefaultEmptyView];
    self.tableView.hidden = NO;
    if (self.isSearching) {
        self.loadingHelper.isRemain = YES;
        self.datasource = [CKList listWithArray:[self createCellItemsWithShops:shops]];
    }
    else {
        self.datasource = $($([self historyHeaderCell],
                            CKJoinArray([self historyRecrodCellList]),
                            [self historyBottomCell]));
    }
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
- (void)requestShopListWithShopName:(NSString *)name {
    @weakify(self);
    [[self.store fetchShopListByName:name] subscribeNext:^(GetShopByNameV2Op *op) {
        
        @strongify(self);
        if (op.rsp_shopArray.count == 0) {
            self.tableView.hidden = YES;
            [self.view showImageEmptyViewWithImageName:@"def_withoutShop" text:@"附近没有您要找的商户"];
        }
        else {
            self.tableView.hidden = NO;
            [self reloadDatasourceWithShops:op.rsp_shopArray];
        }
    } error:^(NSError *error) {
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:error.domain tapBlock:^{
            @strongify(self);
            [self.view hideDefaultEmptyView];
            [self actionSearch];
        }];
    }];
}

- (void)requestMoreShopList {
    @weakify(self);
    [[[self.store fetchMoreShopListByName] initially:^{
        
        @strongify(self);
        self.loadingHelper.isLoading = YES;
        [self.tableView.bottomLoadingView startActivityAnimation];
    }] subscribeNext:^(GetShopByNameV2Op *op) {
        
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

#pragma mark - Action
- (void)actionSearch {
    NSString *word = [self.searchView.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (word.length == 0) {
        return;
    }
    self.isSearching = YES;
    [self saveSearchRecord:word];
    [self reloadDatasourceWithShops:nil];
    [self requestShopListWithShopName:word];
    [self.searchView.searchBar endEditing:YES];
}

- (void)saveSearchRecord:(NSString *)record {
    NSInteger index = [self.searchReacords indexOfObject:record];
    if (index == NSNotFound) {
        [self.searchReacords safetyInsertObject:record atIndex:0];
        [gAppMgr saveInfo:self.searchReacords forKey:SearchHistory];
    }
    else if (index != 0) {
        [self.searchReacords moveObjectAtIndex:index toIndex:0];
        [gAppMgr saveInfo:self.searchReacords forKey:SearchHistory];
    }
}

- (void)cleanSearchHistory {
    [self.searchReacords removeAllObjects];
    [gAppMgr cleanSearchHistory];
    [self reloadDatasourceWithShops:nil];
}

- (void)loadHistoryRecords {
    NSArray *records = [gAppMgr loadSearchHistory];
    self.searchReacords = [NSMutableArray arrayWithArray:records];
    [self reloadDatasourceWithShops:nil];
}

- (void)cleanHistoryRecords {
    [gAppMgr cleanSearchHistory];
    [self reloadDatasourceWithShops:nil];
}

- (void)actionGotoShopDetailWithShop:(JTShop *)shop {
    ShopDetailViewController *vc = [[ShopDetailViewController alloc] init];
    vc.shop = shop;
    vc.serviceType = self.serviceType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionNavigationWithShop:(JTShop *)shop {
    [gPhoneHelper navigationRedirectThirdMap:shop
                             andUserLocation:self.store.coordinate
                                     andView:self.navigationController.view];
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

#pragma mark - Cell
- (CKDict *)historyHeaderCell {
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"historyHeader"}];
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, HKTableTextCell *cell, NSIndexPath *indexPath) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = kBackgroundColor;
        cell.titleLabelInsets = UIEdgeInsetsMake(0, 18, 0, 14);
        cell.titleLabel.font = [UIFont systemFontOfSize:15];
        cell.titleLabel.textColor = kGrayTextColor;
        cell.titleLabel.text = @"搜索历史";
        
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    });
    return dict;
}

- (NSArray *)historyRecrodCellList {
    @weakify(self);
    return [self.searchReacords arrayByMapFilteringOperator:^id(id obj) {
        @strongify(self);
        return [self historyRecordCellWithHistoryRecord:obj];
    }];
}

- (CKDict *)historyRecordCellWithHistoryRecord:(NSString *)record {
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"historyRecord", @"record": record}];
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, HKTableTextCell *cell, NSIndexPath *indexPath) {
        cell.backgroundColor = [UIColor whiteColor];
        cell.titleLabelInsets = UIEdgeInsetsMake(0, 18, 0, 14);
        cell.titleLabel.font = [UIFont systemFontOfSize:15];
        cell.titleLabel.textColor = kDarkTextColor;
        cell.titleLabel.text = data[@"record"];

        BOOL tail = indexPath.row == [self.datasource[indexPath.section] count] - 1;
        UIEdgeInsets bottomLineInsets = tail ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 14, 0, 14);
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:bottomLineInsets];
    });
    
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        self.searchView.searchBar.text = data[@"record"];
        [self actionSearch];
    });

    return dict;
}

- (CKDict *)historyBottomCell {
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"historyBottom"}];
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });

    @weakify(self);
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, HKTableTextCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.titleLabel.font = [UIFont systemFontOfSize:13];
        cell.titleLabel.textColor = kDarkTextColor;
        cell.titleLabel.textAlignment = NSTextAlignmentCenter;
        cell.titleLabel.text = self.searchReacords.count == 0 ? @"无搜索记录" : @"清空搜索历史";
    });
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        if (self.searchReacords.count > 0) {
            [self cleanSearchHistory];
        }
    });
    return dict;
}


- (CKDict *)titleCellWithShop:(JTShop *)shop {
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"title", @"shop": shop}];
    dict[@"distance"] = [DistanceCalcHelper getDistanceStrLatA:self.store.coordinate.latitude
                                                          lngA:self.store.coordinate.longitude
                                                          latB:shop.shopLatitude
                                                          lngB:shop.shopLongitude];
    dict[@"rate"] = [NSString stringWithFormat:@"%@分",
                     [@(shop.shopRate) decimalStringWithMaxFractionDigits:1 minFractionDigits:1]];
    
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, ShopListTitleCell *cell, NSIndexPath *indexPath) {
        
        JTShop *shop = dict[@"shop"];
        [cell.logoView setImageByUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail
                            defImage:@"cm_shop" errorImage:@"cm_shop"];
        cell.titleLabel.text = shop.shopName;
        cell.ratingView.ratingValue = shop.shopRate;
        cell.rateLabel.text = dict[@"rate"];
        cell.commentLabel.text = [NSString stringWithFormat:@"%ld", shop.ratenumber];
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

- (nullable CKDict *)serviceCellWithShop:(JTShop *)shop andService:(JTShopService *)service {
    if (!shop || !service) {
        return nil;
    }
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"service", @"shop": shop}];
    dict[@"service"] = [ShopListStore descForShopServiceWithService:service andShop:shop];
    dict[@"price"] = [ShopListStore markupForShopServicePrice:service];
    
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, ShopListServiceCell *cell, NSIndexPath *indexPath) {
        cell.serviceLabel.text = dict[@"service"];
        [cell.priceLabel setMarkup:dict[@"price"]];
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 14)];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
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
            [self actionNavigationWithShop:data[@"shop"]];
        }];
        
        [[[cell.phoneButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            JTShop *shop = data[@"shop"];
            [self actionMakeCallWithPhoneNumber:shop.shopPhone];
        }];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    dict[kCKCellWillDisplay] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
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
    return self.isSearching ? 10 : CGFLOAT_MIN;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchView.searchBar endEditing:YES];
}

#pragma mark - UISearchBarDelegate 
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [MobClick event:@"rp103_4"];
    [self actionSearch];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    return YES;
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (self.isSearching && searchText.length == 0) {
        self.isSearching = NO;
        [self reloadDatasourceWithShops:nil];
    }
}

@end
