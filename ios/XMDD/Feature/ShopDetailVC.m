//
//  ShopDetailVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailVC.h"
#import "ShopDetailCollectionLayout.h"
#import "DistanceCalcHelper.h"
#import "NSString+RectSize.h"
#import "NSNumber+Format.h"
#import "ShopDetailStore.h"
#import "HKLoadingHelper.h"
#import "UILabel+MarkupExtensions.h"
#import "ShopDetailHeaderView.h"
#import "ShopDetailNavigationBar.h"
#import "ShopDetailTitleCell.h"
#import "ShopDetailActionCell.h"
#import "ShopDetailServiceSegmentCell.h"
#import "ShopDetailServiceDescCell.h"
#import "ShopDetailServiceCell.h"
#import "ShopDetailPaymentCell.h"
#import "ShopDetailServiceSwitchCell.h"
#import "ShopDetailCommentTitleCell.h"
#import "ShopDetailCommentLoadingCell.h"
#import "ShopDetailCommentCell.h"
#import "CarWashNavigationViewController.h"
#import "ShopCommentListVC.h"
#import "PayForWashCarVC.h"

typedef void (^PrepareCollectionCellBlock)(CKDict *item, NSIndexPath *indexPath, __kindof UICollectionViewCell *cell);
@interface ShopDetailVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) ShopDetailCollectionLayout *collectionLayout;
@property (nonatomic, strong) ShopDetailNavigationBar *customNavBar;
@property (nonatomic, strong) ShopDetailHeaderView *headerView;

@property (nonatomic, strong) ShopDetailStore *store;
@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, assign) NSInteger segmentIndex;
@property (nonatomic, assign) HKLoadStatus loadStatus;
@property (nonatomic, assign) BOOL shouldExpandServices;
@property (nonatomic, strong) NSDictionary *mobEventTags;
@end

@implementation ShopDetailVC

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.store = [ShopDetailStore fetchOrCreateStoreByShopID:self.shop.shopID];
    [self.store resetDataWithShop:self.shop];
    
    [self setupAllMobEvents];
    [self setupCollectionView];
    [self setupNavitationBar];
    [self setupHeaderView];
    [self setupSignals];
    [self reloadDatasource];
    [self.store fetchAllCommentGroups];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.headerView.trottingView refreshLabels];
    self.customNavBar.isCollected = self.store.isShopCollected;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.customNavBar.titleDidShowed ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma mark - Setup

- (void)setupCollectionView {
    self.collectionLayout = [[ShopDetailCollectionLayout alloc] init];
    self.collectionLayout.minimumLineSpacing = 0;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.collectionLayout];
    self.collectionView.contentInset = UIEdgeInsetsMake(165, 0, 10, 0);
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = kBackgroundColor;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    [self.view addSubview:self.collectionView];

    [self.collectionView registerClass:[ShopDetailTitleCell class] forCellWithReuseIdentifier:@"title"];
    [self.collectionView registerClass:[ShopDetailActionCell class] forCellWithReuseIdentifier:@"action"];
    [self.collectionView registerClass:[ShopDetailServiceSegmentCell class] forCellWithReuseIdentifier:@"serviceSegment"];
    [self.collectionView registerClass:[ShopDetailServiceDescCell class] forCellWithReuseIdentifier:@"serviceDesc"];
    [self.collectionView registerClass:[ShopDetailServiceCell class] forCellWithReuseIdentifier:@"serviceItem"];
    [self.collectionView registerClass:[ShopDetailPaymentCell class] forCellWithReuseIdentifier:@"servicePayment"];
    [self.collectionView registerClass:[ShopDetailServiceSwitchCell class] forCellWithReuseIdentifier:@"serviceSwitch"];
    [self.collectionView registerClass:[ShopDetailCommentTitleCell class] forCellWithReuseIdentifier:@"commentTitle"];
    [self.collectionView registerClass:[ShopDetailCommentLoadingCell class] forCellWithReuseIdentifier:@"commentLoading"];
    [self.collectionView registerClass:[ShopDetailCommentCell class] forCellWithReuseIdentifier:@"commentItem"];
}

- (void)setupNavitationBar {
    // 隐藏系统导航条
    self.router.navigationBarHidden = YES;
    self.customNavBar = [[ShopDetailNavigationBar alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 64)
                                                         andScrollView:self.collectionView];
    self.customNavBar.titleLabel.text = @"商户详情";
    @weakify(self);
    //更新状态栏
    [self.customNavBar setShouldUpdateStatusBar:^(void) {
        @strongify(self);
        [self setNeedsStatusBarAppearanceUpdate];
    }];
    
    // 点击返回
    [self.customNavBar setActionDidBack:^{
        @strongify(self);
        [self actionBack:nil];
    }];
    
    // 点击 收藏/取消收藏
    [self.customNavBar setActionDidCollect:^{
        @strongify(self);
        [self mobClickWithEventKey:@"collect"];
        if (self.customNavBar.isCollected) {
            [self actionUncollect:nil];
        }
        else {
            [self actionCollect:nil];
        }
    }];

    [self.view addSubview:self.customNavBar];
}

- (void)setupHeaderView {
    self.headerView = [[ShopDetailHeaderView alloc] initWithFrame:CGRectMake(0, -165, ScreenWidth, 165)];
    [self.collectionView addSubview:self.headerView];

    self.headerView.trottingView.text = [self.store stringWithAppendSpace:_shop.announcement andWidth:ScreenWidth - 62];
    self.headerView.trottingContainerView.hidden = self.shop.announcement.length == 0;
    self.headerView.picURLArray = self.shop.picArray;
    [[self.headerView.tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        [self mobClickWithEventKey:@"header"];
    }];
}

- (void)setupSignals {
    @weakify(self);
    [[[RACObserve(self.store, reloadAllCommentsSignal) distinctUntilChanged] skip:1]
     subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            self.loadStatus = HKLoadStatusLoading;
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            self.loadStatus = HKLoadStatusSuccess;
            [self reloadComments];
        } error:^(NSError *error) {
            
            @strongify(self);
            self.loadStatus = HKLoadStatusError;
        }];
    }];
}
#pragma mark - Datasource
- (void)reloadDatasource {
    NSNumber *groupkey = [self.store serviceGroupKeyForServiceType:self.serviceType];
    self.segmentIndex = [self.store.serviceGroups indexOfObjectForKey:groupkey];
    [self.store selectServiceGroup:self.store.serviceGroups[self.segmentIndex]];
    
    self.datasource = $($([self titleCell], [self addressCell], [self phoneCell], [self serviceSegmentCell]),
                        [self createServiceSectionItems],
                        [self createCommentSectionItems]);
    [self.collectionView reloadData];
}

- (id)createServiceSectionItems {
    NSArray *allServices = [self.store.selectedServiceGroup allObjects];
    ShopServiceType type = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
    if (type == ShopServiceCarMaintenance && allServices.count > 2 && !self.shouldExpandServices) {
        allServices = [allServices subarrayToIndex:2];
    }
    NSArray *serviceItems = [allServices arrayByMapFilteringOperator:^id(id obj) {
        return [self serviceItemCellWithService:obj];
    }];
    
    CKList *section = $([self serviceDescCell],
                        CKJoinArray(serviceItems),
                        [self serviceSwitchCell],
                        [self servicePaymentCell]);
    [section setKey:@"serviceSection"];
    return section;
}

- (id)createCommentSectionItems {
    NSArray *comments = [[self.store currentCommentList] allObjects];
    NSMutableArray *commentItems = [NSMutableArray array];
    for (NSInteger i = 0; i < 5 && i < comments.count; i++) {
        [commentItems safetyAddObject:[self commentItemCellWithComment:comments[i]]];
    }

    CKList *section = $([self commentTitleCell],
                        [self commentLoadingCell],
                        CKJoinArray(commentItems));
    [section setKey:@"commentSection"];
    return section;
}

- (void)reloadComments {
    NSInteger index = [self.datasource indexOfObjectForKey:@"commentSection"];
    [self.datasource replaceObject:[self createCommentSectionItems] forKey:@"commentSection"];
    self.collectionLayout.animationType = ShopDetailCollectionAnimateDefault;
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:index]];
}

#pragma mark - Action
- (void)actionBack:(id)sender {
    [super actionBack:sender];
    [self mobClickWithEventKey:@"back"];
}
/// 收藏
- (void)actionCollect:(id)sender {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        @weakify(self);
        [[[self.store collectShop] initially:^{
            
            [gToast showingWithText:@"添加中…"];
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            [gToast dismiss];
            self.customNavBar.isCollected = YES;
        } error:^(NSError *error) {
            
            [gToast showError:error.domain];
        }];
    }
}

/// 取消收藏
- (void)actionUncollect:(id)sender {
    if ([LoginViewModel loginIfNeededForTargetViewController:self]) {
        @weakify(self);
        [[[self.store unCollectShop] initially:^{
            
            [gToast showingWithText:@"移除中…"];
        }] subscribeNext:^(id x) {
            
            @strongify(self);
            [gToast dismiss];
            self.customNavBar.isCollected = NO;
        } error:^(NSError *error) {
            
            [gToast showError:error.domain];
        }];
    }
}

/// 跳转到地图页面
- (void)actionGotoMapVC {
    [self mobClickWithEventKey:@"map"];
    CarWashNavigationViewController * vc = [[CarWashNavigationViewController alloc] init];
    vc.shop = self.shop;
    vc.favorite = self.customNavBar.isCollected;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 拨打商户电话
- (void)actionMakeCall {
    [self mobClickWithEventKey:@"phone"];
    if (self.shop.shopPhone.length == 0) {
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"好吧" color:kDefTintColor clickBlock:nil];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb"
                                                          Message:@"该店铺没有电话~" ActionItems:@[cancel]];
        [alert show];
    }
    else {
        [gPhoneHelper makePhone:self.shop.shopPhone andInfo:self.shop.shopPhone];
    }
}

- (void)serivceSegmentDidChanged:(UISegmentedControl *)segmentControl {
    NSInteger oldIndex = self.segmentIndex;
    NSInteger newIndex = segmentControl.selectedSegmentIndex;
    ShopServiceType oldType = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
    ShopServiceType newType = oldType;
    if (oldIndex != newIndex) {
        self.segmentIndex = newIndex;
        [self.store selectServiceGroup:self.store.serviceGroups[newIndex]];
        newType = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
        self.collectionLayout.animationType = oldIndex < newIndex ? ShopDetailCollectionScrollRightToLeft : ShopDetailCollectionScrollLeftToRight;
        @weakify(self);
        [self.collectionView performBatchUpdates:^{
            @strongify(self);
            NSInteger index1 = [self.datasource indexOfObjectForKey:@"serviceSection"];
            NSInteger index2 = [self.datasource indexOfObjectForKey:@"commentSection"];
            [self.datasource replaceObject:[self createServiceSectionItems] forKey:@"serviceSection"];
            [self.datasource replaceObject:[self createCommentSectionItems] forKey:@"commentSection"];
            NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSetWithIndex:index1];
            [indexSet addIndex:index2];
            [self.collectionView reloadSections:indexSet];
        } completion:^(BOOL finished) {
            
        }];
    }
    [self mobClickWithEventKey:[NSString stringWithFormat:@"segment-%ld-%ld", oldType, newType]];
}

- (void)actionSelectServiceCell:(CKDict *)cell {
    JTShopService *oldService = [self.store currentSelectedService];
    JTShopService *newService = cell[@"service"];

//  友盟点击事件
    NSInteger serviceIndex = [self.store.selectedServiceGroup indexOfObjectForKey:newService.key];
    ShopServiceType type = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
    NSString *strtag = [self.mobEventTags objectForKey:[NSString stringWithFormat:@"service-%ld", type]];
    if (serviceIndex != NSNotFound && strtag) {
        [self mobClickWithEventTag:[strtag integerValue] + serviceIndex];
    }

    CKDict *oldCell = self.datasource[@"serviceSection"][oldService.key];
    [self.store selectService:newService];
// 刷新UI
    oldCell.forceReload = !oldCell.forceReload;
    cell.forceReload = !cell.forceReload;
    self.store.selectedServices.forceReload = !self.store.selectedServices.forceReload;
}

- (void)actionPayment:(id)sender {

    ShopServiceType type = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
    [self mobClickWithEventKey:[NSString stringWithFormat:@"pay-%ld", type]];
    PayForWashCarVC *vc = [UIStoryboard vcWithId:@"PayForWashCarVC" inStoryboard:@"Carwash"];
    vc.service = [self.store currentSelectedService];
    vc.shop = self.shop;
    vc.coupon = self.coupon;
    vc.originVC = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionGotoCommentListVC {
    ShopCommentListVC *vc = [[ShopCommentListVC alloc] init];
    vc.shopID = self.shop.shopID;
    vc.serviceType = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
    vc.commentArray = [[self.store currentCommentList] allObjects];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionCloseServiceItems {
    [self mobClickWithEventKey:@"close-servcies"];
    CKList *serviceSection = self.datasource[@"serviceSection"];
    NSInteger section = [self.datasource indexOfObjectForKey:@"serviceSection"];
    NSMutableArray *indexPaths = [NSMutableArray array];

    NSInteger startIndex = [serviceSection indexOfObjectForKey:[self.store.selectedServiceGroup[2] key]];
    NSInteger endIndex = [serviceSection indexOfObjectForKey:@"serviceSwitch"];
    [serviceSection removeObjectsInRange:NSMakeRange(startIndex, endIndex-startIndex)];
    for (NSInteger i = startIndex; i < endIndex; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
    [self.collectionView deleteItemsAtIndexPaths:indexPaths];
}

- (void)actionOpenServiceItems {
    [self mobClickWithEventKey:@"open-services"];
    CKList *serviceSection = self.datasource[@"serviceSection"];
    NSInteger section = [self.datasource indexOfObjectForKey:@"serviceSection"];
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    NSArray *newServices = [self.store.selectedServiceGroup objectsFromIndex:2];
    NSArray *newItems = [newServices arrayByMapFilteringOperator:^id(id obj) {
        return [self serviceItemCellWithService:obj];
    }];
    
    NSInteger index = [serviceSection indexOfObjectForKey:[self.store.selectedServiceGroup[1] key]];
    for (NSInteger i = 0; i < newItems.count; i++) {
        CKDict *item = newItems[i];
        NSInteger row = index + i + 1;
        [serviceSection insertObject:item withKey:item.key atIndex:row];
        [indexPaths addObject:[NSIndexPath indexPathForRow:row inSection:section]];
    }
    [self.collectionView insertItemsAtIndexPaths:indexPaths];
}

#pragma mark - Cell
- (CKDict *)titleCell {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"title", kCKCellID:@"title"}];
    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *item, NSIndexPath *indexPath, ShopDetailTitleCell *cell) {
        @strongify(self);
        cell.titleLabel.text = self.shop.shopName;
        cell.tipLabel.text = [self.shop descForBusinessStatus];
        cell.isTipHighlight = [self.shop.isVacation integerValue] == 0 && self.shop.isInBusinessHours;
        cell.timeLabel.text = [NSString stringWithFormat:@"营业时间：%@ - %@",self.shop.openHour, self.shop.closeHour];
        cell.distanceLabel.text = [DistanceCalcHelper getDistanceStrLatA:gMapHelper.coordinate.latitude
                                                                    lngA:gMapHelper.coordinate.longitude
                                                                    latB:self.shop.shopLatitude
                                                                    lngB:self.shop.shopLongitude];
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 0)];
    };
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 65;
    });
    return dict;
}

- (CKDict *)addressCell {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"address", kCKCellID:@"action"}];
    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *item, NSIndexPath *indexPath, ShopDetailActionCell *cell) {
        @strongify(self);
        cell.titleLabel.text = self.shop.shopAddress;
        cell.imageView.image = [UIImage imageNamed:@"icon_navigation_3_0"];
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 0)];
    };
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 46;
    });
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [self actionGotoMapVC];
    });
    return dict;
}

- (CKDict *)phoneCell {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"phone", kCKCellID:@"action"}];
    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *item, NSIndexPath *indexPath, ShopDetailActionCell *cell) {
        @strongify(self);
        cell.titleLabel.text = [NSString stringWithFormat:@"联系电话：%@", self.shop.shopPhone];
        cell.imageView.image = [UIImage imageNamed:@"icon_phone_3_0"];
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 14, 0, 0)];
    };
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 46;
    });
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [self actionMakeCall];
    });
    return dict;
}

- (id)serviceSegmentCell {
    @weakify(self);
    NSArray *segmentItems = [[self.store.serviceGroups allObjects] arrayByMappingOperator:^id(CKList *group) {
        @strongify(self);
        return [self.store serviceGroupDescForServiceGroup:group];
    }];
    if ([segmentItems count] < 2) {
        return CKNULL;
    }
    
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"serviceSegment", kCKCellID:@"serviceSegment"}];
    dict[@"segmentItems"] = segmentItems;
    
    dict[kCKCellPrepare] = ^(CKDict *item, NSIndexPath *indexPath, ShopDetailServiceSegmentCell *cell) {
        
        @strongify(self);
        [cell setupSegmentControlWithItems:item[@"segmentItems"]];
        [cell.segmentControl setSelectedSegmentIndex:self.segmentIndex];
        
        [[[cell.segmentControl rac_signalForControlEvents:UIControlEventValueChanged]
         takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(UISegmentedControl *segmentControl) {
            
            @strongify(self);
            [self serivceSegmentDidChanged:segmentControl];
        }];
    };
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 55;
    });
    return dict;
}

- (id)serviceDescCell {
    if ([ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup] != ShopServiceCarMaintenance) {
        return CKNULL;
    }
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"serviceDesc", kCKCellID:@"serviceDesc"}];
    dict[@"desc"] = [gStoreMgr.configStore maintenanceDesc];
    
    dict[kCKCellPrepare] = ^(CKDict *item, NSIndexPath *indexPath, ShopDetailServiceDescCell *cell) {
        cell.descLabel.text = item[@"desc"];
    };
    
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return [ShopDetailServiceDescCell cellHeightWithDesc:data[@"desc"] contentWidth:ScreenWidth];
    });
    
    return dict;
}

- (CKDict *)serviceItemCellWithService:(JTShopService *)service {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:service.key, kCKCellID:@"serviceItem", @"service": service}];
    dict[@"title"] = service.serviceName;
    dict[@"desc"] = service.serviceDescription;
    dict[@"price"] = [ShopDetailStore markupStringWithOldPrice:service.oldOriginPrice curPrices:service.origprice];

    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return [ShopDetailServiceCell cellHeightWithTitle:data[@"title"] desc:data[@"desc"] boundWidth:ScreenWidth];
    });

    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *data, NSIndexPath *indexPath, ShopDetailServiceCell *cell) {
        cell.titleLabel.text = data[@"title"];
        [cell.priceLabel setMarkup:data[@"price"]];
        cell.descLabel.text = data[@"desc"];
        
        @strongify(self);
        [[[cell.radioButton rac_signalForControlEvents:UIControlEventTouchUpInside]
          takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            [self actionSelectServiceCell:data];
        }];
        
        @weakify(data, cell);
        [[RACObserve(data, forceReload) takeUntilForCell:cell] subscribeNext:^(id x) {
            
            @strongify(self, data, cell);
            JTShopService *service = data[@"service"];
            JTShopService *curService = [self.store currentSelectedService];
            cell.radioButton.selected = [service.serviceID isEqual:curService.serviceID];
        }];
    };
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        [self actionSelectServiceCell:data];
    });
    
    return dict;
}

- (id)serviceSwitchCell {
    NSNumber *serviceSectionKey = (NSNumber *)self.store.selectedServiceGroup.key;
    // 如果不是小保养或者服务项目少于2条，则不显示
    if (![serviceSectionKey isEqual:@(ShopServiceCarMaintenance)] || self.store.selectedServiceGroup.count <= 2) {
        return CKNULL;
    }
    
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"serviceSwitch", kCKCellID:@"serviceSwitch"}];
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 33;
    });
    
    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *data, NSIndexPath *indexPath, ShopDetailServiceSwitchCell *cell) {
        @strongify(self);
        NSString *title = [self titleForServiceSwitchCell];
        [cell setExpand:self.shouldExpandServices title:title animated:NO];
    };
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        ShopDetailServiceSwitchCell *cell = (ShopDetailServiceSwitchCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        self.shouldExpandServices = !self.shouldExpandServices;
        [cell setExpand:self.shouldExpandServices title:[self titleForServiceSwitchCell] animated:YES];
        if (self.shouldExpandServices) {
            [self actionOpenServiceItems];
        }
        else {
            [self actionCloseServiceItems];
        }
    });
    return dict;
}

- (CKDict *)servicePaymentCell {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"servicePayment", kCKCellID:@"servicePayment"}];
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 46;
    });

    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *data, NSIndexPath *indexPath, ShopDetailPaymentCell *cell) {
        @strongify(self);
        [cell.payButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
        [cell.payButton addTarget:self action:@selector(actionPayment:) forControlEvents:UIControlEventTouchUpInside];
        
        @weakify(cell);
        [[RACObserve(self.store.selectedServices, forceReload) takeUntilForCell:cell] subscribeNext:^(id x) {
            @strongify(self, cell);
            JTShopService *service = [self.store currentSelectedService];
            cell.priceLabel.text = [NSString stringWithFormat:@"￥%@", [@(service.origprice) priceString]];
        }];

        
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, 14, 0, 0)];
    };
    return dict;
}

- (CKDict *)commentTitleCell {
    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"commentTitle", kCKCellID:@"commentTitle"}];
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 42;
    });
    
    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *data, NSIndexPath *indexPath, ShopDetailCommentTitleCell *cell) {
        @strongify(self);
        cell.ratingView.ratingValue = self.shop.shopRate;
        
        NSString *rateStr = [@(self.shop.shopRate) decimalStringWithMaxFractionDigits:1 minFractionDigits:1];
        cell.rateLabel.text = [NSString stringWithFormat:@"%@分", rateStr];

        NSString *commentTitle = [NSString stringWithFormat:@"全部评价(%ld)%@",
                                  [self.store currentCommentNumber],
                                  self.shop.ratenumber == 0 ? @"" : @">"];
        [cell.commentButton setTitle:commentTitle forState:UIControlStateNormal];
    };
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        ShopServiceType type = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
        [self mobClickWithEventKey:[NSString stringWithFormat:@"all-comments-%ld", type]];
        if ([[self.store currentCommentList] count] > 0) {
            [self actionGotoCommentListVC];
        }
    });
    return dict;
}

- (id)commentLoadingCell {
    if (self.loadStatus == HKLoadStatusSuccess && [[self.store currentCommentList] count] > 0) {
        return CKNULL;
    }

    CKDict *dict = [CKDict dictWith:@{kCKItemKey:@"commentLoading", kCKCellID:@"commentLoading"}];
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    
    @weakify(self);
    dict[kCKCellPrepare] = ^(CKDict *data, NSIndexPath *indexPath, ShopDetailCommentLoadingCell *cell) {
        @strongify(self);
        [[RACObserve(self, loadStatus) takeUntilForCell:cell] subscribeNext:^(NSNumber *statusNumber) {
            HKLoadStatus status = [statusNumber integerValue];
            if (status == HKLoadStatusLoading) {
                cell.titleLabel.text = @"加载中...";
                [cell.activityView startAnimating];
            }
            else if (status == HKLoadStatusError) {
                cell.titleLabel.text = @"评论加载失败";
                [cell.activityView stopAnimating];
            }
            else {
                cell.titleLabel.text = @"暂无评价，您可以成为第一人";
                [cell.activityView stopAnimating];
            }
        }];
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, 14, 0, 0)];
    };
    
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        if (self.loadStatus == HKLoadStatusError) {
            [self.store fetchAllCommentGroups];
        }
    });
    return dict;
}

- (CKDict *)commentItemCellWithComment:(JTShopComment *)comment {
    CKDict *dict = [CKDict dictWith:@{kCKCellID:@"commentItem"}];
    dict[@"comment"] = comment;
    dict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        JTShopComment *comment = data[@"comment"];
        return [ShopCommentCell cellHeightWithComment:comment.comment andBoundsWidth:ScreenWidth];
    });
    
    dict[kCKCellPrepare] = ^(CKDict *data, NSIndexPath *indexPath, ShopDetailCommentCell *cell) {
        JTShopComment *comment = data[@"comment"];
        [cell.commentView.logoView setImageByUrl:comment.avatarUrl withType:ImageURLTypeThumbnail
                                        defImage:@"avatar_default" errorImage:@"avatar_default"];
        cell.commentView.titleLabel.text = comment.nickname.length ? comment.nickname : @"无昵称用户";
        cell.commentView.timeLabel.text = [comment.time dateFormatForYYMMdd2];
        cell.commentView.ratingView.ratingValue = comment.rate;
        cell.commentView.serviceLabel.text = [NSString stringWithFormat:@"服务项目：%@", comment.serviceName];
        cell.commentView.commentLabel.text = comment.comment;
        
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsMake(0, 14, 0, 0)];
    };
    
    @weakify(self);
    dict[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        ShopServiceType type = [ShopDetailStore serviceTypeForServiceGroup:self.store.selectedServiceGroup];
        [self mobClickWithEventKey:[NSString stringWithFormat:@"comment-%ld", type]];
    });
    
    return dict;
}

#pragma mark - UICollectionViewDelegate
#pragma mark <UIScrollViewDelegate> 
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOffset = scrollView.contentOffset.y;
    if (yOffset < -165) {
        self.headerView.frame = CGRectMake(0, yOffset, ScreenWidth, fabs(yOffset));
    }
    else if(!CGRectEqualToRect(self.headerView.frame, CGRectMake(0, -165, ScreenWidth, 165))) {
        self.headerView.frame = CGRectMake(0, -165, ScreenWidth, 165);
    }
}

#pragma mark <UICollectionViewDelegateFlowLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    CGFloat height = 44;
    
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    if (block) {
        height= block(item, indexPath);
    }
    return CGSizeMake(ScreenWidth, height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    //评论的section
    if ([@"commentSection" isEqualToString:[self.datasource[section] key]]) {
        return UIEdgeInsetsMake(10, 0, 0, 0);
    }
    return UIEdgeInsetsZero;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.datasource count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.datasource[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:item[kCKCellID] forIndexPath:indexPath];
    PrepareCollectionCellBlock block = item[kCKCellPrepare];
    if (block) {
        block(item, indexPath, cell);
    }
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = item[kCKCellSelected];
    if (block) {
        block(item, indexPath);
    }
}

#pragma mark - Util
- (NSString *)titleForServiceSwitchCell {
    if (self.shouldExpandServices) {
        return @"收起";
    }
    return [NSString stringWithFormat:@"您还有%ld种选择", [self.store.selectedServiceGroup count] - 2];
}

#pragma mark - UMeng
- (void)setupAllMobEvents {
    self.mobEventTags = @{@"back": @"1", @"collect": @"2", @"header": @"3", @"map": @"4",
                          @"phone": @"5", @"open-services": @"9", @"close-services": @"13",
                          @"segment-0-0": @"14", @"segment-0-4": @"15", @"segment-0-3": @"16",
                          @"segment-3-0": @"6", @"segment-3-4": @"7", @"segment-3-3": @"8",
                          @"segment-4-0": @"20", @"segment-4-4": @"21", @"segment-4-3": @"22",
                          @"pay-0": @"17", @"pay-3": @"10", @"pay-4": @"23",
                          @"all-comments-0": @"18", @"all-comments-3": @"11", @"all-comments-4": @"24",
                          @"comment-0": @"19", @"comment-3": @"12", @"comment-4": @"25",
                          @"service-0": @"101", @"service-3": @"301", @"service-4": @"201",
                       };
}

- (void)mobClickWithEventKey:(NSString *)key {
    NSString *strtag = self.mobEventTags[key];
    if (strtag) {
        [self mobClickWithEventTag:[strtag integerValue]];
    }
}

- (void)mobClickWithEventTag:(NSInteger)tag {
    NSString *value = [NSString stringWithFormat:@"shangjiaxiangqing%ld", tag];
    [MobClick event:@"shangjiaxiangqing" attributes:@{@"shangjiaxiangqing": value}];
}

@end
