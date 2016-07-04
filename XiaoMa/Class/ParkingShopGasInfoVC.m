//
//  ParkingShopGasInfoVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 6/28/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "ParkingShopGasInfoVC.h"
#import "NSString+RectSize.h"
#import "GetParkingShopGasInfoOp.h"
#import "AreaTablePickerVC.h"
#import "HKLocationDataModel.h"
#import "NearbyShopsViewController.h"

@interface ParkingShopGasInfoVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *fetchedDataArray;
@property (nonatomic, strong) CKList *dataSource;

@property (nonatomic, strong) HKLocationDataModel * locationData;
@property (nonatomic, assign) LocateState locateState;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) UIView *bottomTipsView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, strong) NSNumber *pageNo;

@property (nonatomic, strong) NSMutableArray *disposableArray;

@property (nonatomic) BOOL isUpdating;
@property (nonatomic) BOOL noUpdate;

@end

@implementation ParkingShopGasInfoVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"ParkingShopGasInfoVC deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWhenFirstLoad];
    [self setupRefreshView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Actions
- (IBAction)mapViewBarButtonItemClicked:(id)sender
{
    NearbyShopsViewController *nearbyShopView = [carWashStoryboard instantiateViewControllerWithIdentifier:@"NearbyShopsViewController"];
    nearbyShopView.searchType = self.searchType;
    nearbyShopView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:nearbyShopView animated:YES];
}

#pragma mark - Lazy instantiation
- (NSMutableArray *)fetchedDataArray
{
    if (!_fetchedDataArray) {
        _fetchedDataArray = [[NSMutableArray alloc] init];
    }
    
    return _fetchedDataArray;
}

// 显示在 footer 上的提示文字。
- (UIView *)bottomTipsView
{
    if (!_bottomTipsView) {
        // 因为 tableView 有两边 Insets 值，所以 X 值要减去 tableView 的 Insets 值。
        _bottomTipsView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 35)];
        tipsLabel.text = @"已经到底了";
        tipsLabel.font = [UIFont systemFontOfSize:12];
        tipsLabel.textColor = HEXCOLOR(@"#454545");
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        [_bottomTipsView addSubview:tipsLabel];
    }

    return _bottomTipsView;
}

// 显示在 footer 上的刷新图标
- (UIActivityIndicatorView *)spinner
{
    if (!_spinner) {
        _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _spinner.frame = CGRectMake(0, 4, self.view.frame.size.width, 35);
    }

    return _spinner;
}

- (NSMutableArray *)disposableArray
{
    if (!_disposableArray) {
        _disposableArray = [[NSMutableArray alloc] init];
    }
    
    return _disposableArray;
}


#pragma mark - Initial setups
- (void)setupWhenFirstLoad
{
    self.pageNo = @(2);
    
    if (self.searchType.integerValue == 1) {
        self.title = @"停车场";
    } else if (self.searchType.integerValue == 2) {
        self.title = @"附近 4S 店";
    } else {
        self.title = @"加油站";
    }
    
    self.tableView.hidden = YES;
    CGFloat reducingY = self.view.frame.size.height * 0.1056;
    [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
    self.noUpdate = NO;
    [self requestLocation];
}

/// 下拉刷新设置
- (void)setupRefreshView
{
    @weakify(self);
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged] subscribeNext:^(id x) {
        @strongify(self);
        self.noUpdate = NO;
        self.pageNo = @(2);
        
        [self.disposableArray makeObjectsPerformSelector:@selector(dispose)];
        [self.disposableArray removeAllObjects];
        
        [self requestLocation];
    }];
}

#pragma mark - Obtain data
- (void)getDataBySearchType:(NSNumber *)searchType pageNumber:(NSNumber *)pageNo completion:(void(^)(id responseObject, NSError *error))completion
{
    GetParkingShopGasInfoOp *op = [GetParkingShopGasInfoOp operation];
    op.searchType = searchType;
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setPositiveFormat:@"0.######"];
    op.longitude = [format numberFromString:[NSString stringWithFormat:@"%f", self.coordinate.longitude]];
    op.latitude = [format numberFromString:[NSString stringWithFormat:@"%f", self.coordinate.latitude]];
    op.pageNo = pageNo;
    op.range = @(1);
    
    @weakify(self);
    RACDisposable *disposable = [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.isUpdating = YES;
        
    }] subscribeNext:^(GetParkingShopGasInfoOp *rop) {
        
        completion(rop.extShops, nil);
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        [gToast showError:@"请求数据失败，请重试"];
        self.isUpdating = NO;
        completion(nil, error);
    }];
    
    [self.disposableArray addObject:disposable];
}

- (void)setDataSource
{
    self.dataSource = [CKList list];
    NSMutableArray *dataArray = [NSMutableArray new];
    for (NSDictionary *dict in self.fetchedDataArray) {
        
        CKList *dataList = [CKList list];
        
        NSString *nameString = dict[@"name"];
        if (nameString.length > 0) {
            CKDict *titleCell = [self setupTitleCellCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[titleCell]];
        }
        
        NSString *carBrandString = dict[@"carrefname"];
        if (carBrandString.length > 0) {
            CKDict *carBrandCell = [self setupCarBrandCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[carBrandCell]];
        }
        
        NSString *addressString = dict[@"address"];
        NSNumber *distance = dict[@"distance"];
        if (addressString.length > 0 || distance != nil) {
            CKDict *addressCell = [self setupAddressInfoCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[addressCell]];
        }
        
        NSArray *callNumberArray = dict[@"contactphones"];
        if (callNumberArray.count > 0) {
            CKDict *callNumberCell = [self setupCallNumberCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[callNumberCell]];
        }
        
        if (self.searchType.integerValue == 2 || self.searchType.integerValue == 3) {
            CKDict *navigationCallCell = [self setupNavigationCallCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[navigationCallCell]];
        } else {
            CKDict *navigationCell = [self setupNavigationCellWithDictOfData:dict];
            [dataList addObjectsFromArray:@[navigationCell]];
        }
        
        [dataArray addObject:dataList];
    }
    
    self.dataSource = [CKList listWithArray:dataArray];
    
    [self.tableView reloadData];
}

#pragma mark - The settings of cells
- (CKDict *)setupTitleCellCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *titleCell = [CKDict dictWith:@{kCKItemKey:@"titleCell", kCKCellID:@"TitleCell"}];
    
    titleCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    
    titleCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:100];
        
        titleLabel.text = dict[@"name"];
    });
    
    return titleCell;
}

- (CKDict *)setupCarBrandCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *detailInfoCell = [CKDict dictWith:@{kCKItemKey:@"detailInfoCell", kCKCellID:@"DetailInfoCell"}];
    
    detailInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *string = dict[@"carrefname"];
        CGSize size = [string labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 126 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 28);
        return height;
    });
    
    detailInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:102];
        
        imageView.image = [UIImage imageNamed:@"common_carGrayV2_imageView"];
        
        infoLabel.text = dict[@"carrefname"];
        distanceLabel.hidden = YES;
    });
    
    return detailInfoCell;
}

- (CKDict *)setupAddressInfoCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *detailInfoCell = [CKDict dictWith:@{kCKItemKey:@"detailInfoCell", kCKCellID:@"DetailInfoCell"}];
    
    detailInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSString *string = dict[@"address"];
        CGSize size = [string labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 126 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 28);
        return height;
    });
    
    detailInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:102];
        
        imageView.image = [UIImage imageNamed:@"common_locationGrayV2_imageView"];
        
        NSNumber *distance = dict[@"distance"];
        infoLabel.text = dict[@"address"];
        distanceLabel.text = [NSString stringWithFormat:@"%.2fkm", distance.doubleValue];
        distanceLabel.hidden = NO;
    });
    
    return detailInfoCell;
}

- (CKDict *)setupCallNumberCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *detailInfoCell = [CKDict dictWith:@{kCKItemKey:@"detailInfoCell", kCKCellID:@"DetailInfoCell"}];
    
    detailInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        NSArray *callNumberArray = dict[@"contactphones"];
        NSString *string = [callNumberArray componentsJoinedByString:@", "];
        CGSize size = [string labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 126 font:[UIFont systemFontOfSize:13]];
        CGFloat height = size.height + 8;
        height = MAX(height, 28);
        return height;
    });
    
    detailInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:100];
        UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
        UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:102];
        
        imageView.image = [UIImage imageNamed:@"common_callGrayV2_imageView"];
        
        NSArray *callNumberArray = dict[@"contactphones"];
        infoLabel.text = [callNumberArray componentsJoinedByString:@", "];
        distanceLabel.hidden = YES;
    });
    
    return detailInfoCell;
}

- (CKDict *)setupNavigationCallCellWithDictOfData:(NSDictionary *)dict
{
    CKDict *navigationCallCell = [CKDict dictWith:@{kCKItemKey:@"navigationCallCell", kCKCellID:@"NavigationCallCell"}];
    
    navigationCallCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 59;
    });
    
    @weakify(self)
    navigationCallCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *navigationButton = (UIButton *)[cell.contentView viewWithTag:100];
        UIButton *callButton = (UIButton *)[cell.contentView viewWithTag:101];
        
        NSArray *callNumberArray = dict[@"contactphones"];
        
        JTShop *shop = [[JTShop alloc] init];
        shop.shopName = dict[@"name"];
        shop.shopLongitude = [dict[@"longitude"] doubleValue];
        shop.shopLatitude = [dict[@"latitude"] doubleValue];
        
        [callButton setTitleColor:HEXCOLOR(@"#888888") forState:UIControlStateDisabled];
        [callButton setImage:[UIImage imageNamed:@"common_callGrayV2_imageView"] forState:UIControlStateDisabled];
        
        [[[navigationButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.coordinate andView:self.tabBarController.view];
        }];
        
        if (callNumberArray.count > 0) {
            callButton.enabled = YES;
        } else {
            callButton.enabled = NO;
        }
        
        
        [[[callButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            UIActionSheet *callSheet = [[UIActionSheet alloc] initWithTitle:@"请选择需要拨打的电话" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil];
            for (NSString *number in callNumberArray) {
                [callSheet addButtonWithTitle:number];
            }
            [callSheet showInView:self.view];
            
            [[callSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
                NSInteger buttonIndex = [number integerValue];
                if (buttonIndex == [callSheet cancelButtonIndex]) {
                    return ;
                } else {
                    NSString * phone = [callSheet buttonTitleAtIndex:buttonIndex];
                    [gPhoneHelper makePhone:phone andInfo:phone];
                }
            }];
        }];
        
    });
    
    return navigationCallCell;
}

- (CKDict *)setupNavigationCellWithDictOfData:(NSDictionary *)dict
{
    
    CKDict *navigationCell = [CKDict dictWith:@{kCKItemKey:@"navigationCell", kCKCellID:@"NavigationCell"}];
    
    navigationCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 59;
    });
    
    @weakify(self)
    navigationCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self)
        UIButton *navigationButton = (UIButton *)[cell.contentView viewWithTag:100];
        
        JTShop *shop = [[JTShop alloc] init];
        shop.shopName = dict[@"name"];
        shop.shopLongitude = [dict[@"longitude"] doubleValue];
        shop.shopLatitude = [dict[@"latitude"] doubleValue];
        
        @weakify(self)
        [[[navigationButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self)
            [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.coordinate andView:self.tabBarController.view];
        }];
    });
    
    return navigationCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CKList *cellList = self.dataSource[section];
    NSArray *countArray = [cellList allObjects];
    return countArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    if (section == self.dataSource.count - 1) {
        return 40;
    }
    
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == self.dataSource.count - 1) {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 46)];
        [containerView addSubview:self.spinner];
        [containerView addSubview:self.bottomTipsView];
        return containerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.dataSource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:item[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = item[kCKCellPrepare];
    
    if (block) {
        block(item, cell, indexPath);
    }
    
    return cell;
}

/// 实现上滑自动刷新的逻辑
- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    if (indexPath.section == self.dataSource.count - 1 && !self.isUpdating && !self.noUpdate) {
        
        // 开始底部 footer 上 spinner 的转动并决定该显示的内容。
        self.bottomTipsView.hidden = YES;
        [self.spinner startAnimating];
        self.spinner.hidden = NO;
        
        
        @weakify(self)
        [self getDataBySearchType:self.searchType pageNumber:self.pageNo completion:^(id responseObject, NSError *error) {
            
            @strongify(self)
            if (responseObject) {
                NSArray *responsedArray = responseObject;
                self.tableView.hidden = NO;
                [self.view stopActivityAnimation];
                [self.view hideDefaultEmptyView];
                [self.tableView.refreshView endRefreshing];
                
                if (responsedArray.count > 0) {
                    [self.fetchedDataArray addObjectsFromArray:responsedArray];
                    [self setDataSource];
                } else {
                    self.bottomTipsView.hidden = NO;
                    [self.spinner stopAnimating];
                    self.noUpdate = YES;
                }
                
                self.isUpdating = NO;
            }
            
            if (!error) {
                self.pageNo = @(self.pageNo.integerValue + 1);
            }
        }];
    }
}


#pragma mark - Get location & GEO information
- (void)requestLocation
{
    self.locationData = [[HKLocationDataModel alloc] init];
    self.locateState = LocateStateLocating;
    @weakify(self);
    [[[gMapHelper rac_getUserLocationAndInvertGeoInfo] flattenMap:^RACStream *(id value) {
        @strongify(self);
        self.locationData.province = gMapHelper.addrComponent.province;
        self.locationData.city = gMapHelper.addrComponent.city;
        self.coordinate = gMapHelper.coordinate;
        self.locateState = LocateStateSuccess;
        
        GetAreaByPcdOp *op = [GetAreaByPcdOp operation];
        op.req_province = gMapHelper.addrComponent.province;
        op.req_city = gMapHelper.addrComponent.city;
        return [op rac_postRequest];
    }] subscribeNext:^(GetAreaByPcdOp * op) {
        
        @strongify(self);
        [self getDataBySearchType:self.searchType pageNumber:@(1) completion:^(id responseObject, NSError *error) {
            @strongify(self);
            if (responseObject) {
                NSArray *dataArray = responseObject;
                self.tableView.hidden = NO;
                [self.view stopActivityAnimation];
                [self.view hideDefaultEmptyView];
                [self.tableView hideDefaultEmptyView];
                [self.tableView.refreshView endRefreshing];
                
                if (dataArray.count > 0) {
                    [self.fetchedDataArray removeAllObjects];
                    [self.fetchedDataArray addObjectsFromArray:dataArray];
                    [self setDataSource];
                } else {
                    if (self.searchType.integerValue == 1) {
                        [self.tableView showImageEmptyViewWithImageName:@"def_withoutShop" text:@"暂无停车场"];
                    } else if (self.searchType.integerValue == 2) {
                        [self.tableView showImageEmptyViewWithImageName:@"def_withoutShop" text:@"暂无 4S 店"];
                    } else {
                        [self.tableView showImageEmptyViewWithImageName:@"def_withoutShop" text:@"暂无加油站"];
                    }
                }
            }
            
            self.isUpdating = NO;
            
            if (error) {
                self.tableView.hidden = YES;
                
                @weakify(self)
                [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败，点击重试" tapBlock:^{
                    @strongify(self);
                    [self.view hideDefaultEmptyView];
                    CGFloat reducingY = self.view.frame.size.height * 0.17;
                    [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
                    [self requestLocation];
                }];
            }
        }];
        
    } error:^(NSError *error) {
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.tableView.refreshView endRefreshing];
        self.locateState = LocateStateFailure;
        [gToast showError:@"获取城市信息失败"];
        self.tableView.hidden = YES;
        
        @weakify(self)
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败，点击重试" tapBlock:^{
            @strongify(self);
            [self.view hideDefaultEmptyView];
            CGFloat reducingY = self.view.frame.size.height * 0.17;
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
            [self requestLocation];
        }];
    }];
}

@end
