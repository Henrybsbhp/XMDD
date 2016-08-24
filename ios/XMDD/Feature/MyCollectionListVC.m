//
//  MyCollectionVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/23.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyCollectionListVC.h"
#import "DistanceCalcHelper.h"
#import "ShopListStore.h"
#import "ShopDetailStore.h"
#import "UILabel+MarkupExtensions.h"
#import "MyCollectionListBottomView.h"
#import "MyCollectionListTitleCell.h"
#import "ShopListServiceCell.h"
#import "ShopListActionCell.h"
#import "ShopDetailVC.h"

@interface MyCollectionListVC ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) MyCollectionListBottomView *bottomView;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) CKList *selectedCollections;
@end

@implementation MyCollectionListVC

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"我的收藏";
    [self setupTableView];
    [self setupBottomView];
    [self setupSignals];
    [self reloadDatasource];
    [self refreshNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = kBackgroundColor;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, CGFLOAT_MIN)];
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 35, 0);
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerClass:[MyCollectionListTitleCell class] forCellReuseIdentifier:@"title"];
    [_tableView registerClass:[ShopListServiceCell class] forCellReuseIdentifier:@"service"];
    [_tableView registerClass:[ShopListActionCell class] forCellReuseIdentifier:@"action"];
    
    CKAsyncMainQueue(^{
        [_tableView.refreshView addTarget:self action:@selector(actionRefresh:)
                         forControlEvents:UIControlEventValueChanged];
    });
}

- (void)setupBottomView {
    self.bottomView = [[MyCollectionListBottomView alloc] initWithFrame:CGRectZero];
    self.bottomView.hidden = YES;
    [self.bottomView.checkBox addTarget:self action:@selector(actionSelectAll:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView.deleteButton addTarget:self action:@selector(actionDelete:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomView];
    
    @weakify(self);
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(46);
    }];
}

- (void)setupSignals {
    [gStoreMgr.collectionStore.collectionsChanged subscribeNext:^(id x) {
        CKList *selectedShops = [CKList list];
        for (JTShop *shop in [self.selectedCollections allObjects]) {
            JTShop *selectedShop = gStoreMgr.collectionStore.collections[shop.key];
            if (selectedShop){
                [selectedShops addObject:selectedShop forKey:selectedShop.key];
            }
        }
        [self reloadDatasource];
    }];
}
#pragma mark - Datasource
- (void)reloadDatasource {
    NSArray *sections = [[gStoreMgr.collectionStore.collections allObjects] arrayByMapFilteringOperator:^id(JTShop *shop) {
        CKList *section = $([self titleCellWithShop:shop],
                            CKJoin([self serviceCellListWithShop:shop]),
                            [self actionCellWithShop:shop]
                            );
        [section setKey:shop.key];
        return section;
    }];
    self.datasource = [CKList listWithArray:sections];
    [self refreshNavigationBar];
    [self refreshTableView];
}

#pragma mark - Refresh Views
- (void)refreshNavigationBar {
    UIBarButtonItem *rightBtn;
    if (self.datasource.count == 0) {
        rightBtn = nil;
    }
    else if (self.isEditing) {
        rightBtn = [UIBarButtonItem barButtonItemWithTitle:@"完成" target:self action:@selector(actionEndEditing:)];
    }
    else {
        rightBtn = [UIBarButtonItem barButtonItemWithTitle:@"编辑" target:self action:@selector(actionBeginEditing:)];
    }
    self.navigationItem.rightBarButtonItem = rightBtn;
}

- (void)refreshTableView {
    if (self.datasource.count == 0) {
        [self.view showImageEmptyViewWithImageName:@"def_withoutCollection" text:@"您暂未收藏商户"];
    }
    else {
        [self.view hideDefaultEmptyView];
    }
    [self.tableView reloadData];
}

- (void)refreshCheckBox {
    if (self.selectedCollections.count < gStoreMgr.collectionStore.collections.count) {
        self.bottomView.checkBox.selected = NO;
    }
    else {
        self.bottomView.checkBox.selected = YES;
    }
}

#pragma mark - Action
- (void)actionRefresh:(id)sender {
    @weakify(self);
    [[gStoreMgr.collectionStore fetchAllCollections] subscribeNext:^(id x) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [self reloadDatasource];
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.tableView.refreshView endRefreshing];
        [gToast showError:error.domain];
    }];
}

- (void)actionSelectAll:(id)sender {
    NSArray *shops = [gStoreMgr.collectionStore.collections allObjects];
    if (self.selectedCollections.count < shops.count) {
        self.selectedCollections = [CKList listWithArray:shops];
    }
    else {
        self.selectedCollections = nil;
    }
    [self refreshCheckBox];
}

- (void)actionSelect:(CKDict *)item {
    JTShop *shop = item[@"shop"];
    NSInteger index = [self.selectedCollections indexOfObjectForKey:shop.key];
    if (index != NSNotFound) {
        [self.selectedCollections removeObjectAtIndex:index];
    }
    else {
        [self.selectedCollections addObject:shop forKey:shop.key];
    }
    item.forceReload = !item.forceReload;
    [self refreshCheckBox];
}

- (void)actionDelete:(id)sender {
    if (self.selectedCollections.count == 0) {
        [gToast showError:@"请选择一家商户进行删除"];
    }
    @weakify(self);
    [[[gStoreMgr.collectionStore removeCollections:[self.selectedCollections allObjects]] initially:^{
        
        [gToast showingWithText:@"正在删除..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast showSuccess:@"删除成功"];
        [self actionEndEditing:nil];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}

- (void)actionEndEditing:(id)sender {
    self.isEditing = NO;
    self.bottomView.hidden = YES;
    [self refreshNavigationBar];
}

- (void)actionBeginEditing:(id)sender {
    self.isEditing = YES;
    self.bottomView.hidden = NO;
    [self refreshNavigationBar];
}

- (void)actionGotoShopDetail:(JTShop *)shop {
    [MobClick event:@"rp316_2"];
    ShopDetailVC *vc = [[ShopDetailVC alloc] init];
    vc.shop = shop;
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
                             andUserLocation:gMapHelper.coordinate
                                     andView:self.navigationController.view];
}

#pragma mark - Getter
- (CKList *)selectedCollections {
    if (!_selectedCollections) {
        _selectedCollections = [CKList list];
    }
    return _selectedCollections;
}

#pragma mark - Cell
- (CKDict *)titleCellWithShop:(JTShop *)shop {
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"title", @"shop": shop}];
    dict[@"distance"] = [DistanceCalcHelper getDistanceStrLatA:gMapHelper.coordinate.latitude
                                                          lngA:gMapHelper.coordinate.longitude
                                                          latB:shop.shopLatitude
                                                          lngB:shop.shopLongitude];
    @weakify(self);
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MyCollectionListTitleCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        JTShop *shop = dict[@"shop"];
        [cell.logoView setImageByUrl:[shop.picArray safetyObjectAtIndex:0] withType:ImageURLTypeThumbnail
                            defImage:@"cm_shop" errorImage:@"cm_shop"];
        cell.titleLabel.text = shop.shopName;
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

        [[[cell.checkBox rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]]
         subscribeNext:^(id x) {
             @strongify(self);
             [self actionSelect:data];
        }];
        
        @weakify(cell, self);
        [[[RACObserve(self, selectedCollections) merge:RACObserve(data, forceReload)] takeUntilForCell:cell] subscribeNext:^(id x) {
            @strongify(cell, self);
            cell.checkBox.selected = (BOOL)self.selectedCollections[shop.key];
        }];
        
        [[RACObserve(self, isEditing) takeUntilForCell:cell] subscribeNext:^(NSNumber *x) {
            @strongify(cell);
            cell.checkBox.hidden = ![x boolValue];
        }];
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 14)];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 86;
    });
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        if (!self.isEditing) {
            [self actionGotoShopDetail:data[@"shop"]];
        }
    });
    return dict;
}

- (NSArray *)serviceCellListWithShop:(JTShop *)shop {
    NSMutableArray *services = [NSMutableArray array];
    if (shop.shopServiceArray.count > 0) {
        [services addObjectsFromArray:shop.shopServiceArray];
    }
    if (shop.beautyServiceArray.count > 0) {
        [services addObject:shop.beautyServiceArray[0]];
    }
    if (shop.maintenanceServiceArray.count > 0) {
        [services addObject:shop.maintenanceServiceArray[0]];
    }
    return [services arrayByMapFilteringOperator:^id(id obj) {
        return [self serviceCellWithShop:shop andService:obj];
    }];
}

- (nullable CKDict*)serviceCellWithShop:(JTShop *)shop andService:(JTShopService *)service {
    if (!shop || !service) {
        return nil;
    }
    CKDict *dict = [CKDict dictWith:@{kCKCellID: @"service", @"shop": shop}];
    dict[@"service"] = [ShopDetailStore serviceGroupDescForServiceType:service.shopServiceType];
    dict[@"price"] = [ShopListStore markupForShopServicePrice:service];
    
    dict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, ShopListServiceCell *cell, NSIndexPath *indexPath) {

        cell.serviceLabel.text = dict[@"service"];
        [cell.priceLabel setMarkup:dict[@"price"]];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 30;
    });
    
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [self actionGotoShopDetail:data[@"shop"]];
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
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, 14, 0, 14)];
    });
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    return dict;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

@end
