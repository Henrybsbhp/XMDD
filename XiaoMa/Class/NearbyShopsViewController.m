//
//  NearbyShopsViewController.m
//  XiaoMa
//
//  Created by jt on 15-4-22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NearbyShopsViewController.h"
#import "GetShopByRangeV2Op.h"
#import "JTShop.h"
#import "MapBottomView.h"
#import "ShopDetailVC.h"
#import "SYPaginator.h"
#import "AddUserFavoriteOp.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DistanceCalcHelper.h"
#import "GetParkingShopGasInfoOp.h"
#import "MapBottomV2View.h"

/// 超过2km
#define RequestDistance 2000

@interface NearbyShopsViewController ()<UIActionSheetDelegate,SYPaginatorViewDataSource, SYPaginatorViewDelegate>

@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *bottomScrollView;
@property (weak, nonatomic) IBOutlet UIButton *locationMeBtn;

@property (nonatomic, strong) SYPaginatorView *bottomSYView;

@property (nonatomic,strong)NSArray * nearbyShopArray;
@property (nonatomic)CLLocationCoordinate2D userCoordinate;
@property (nonatomic)BOOL needRequestNearbyShop;

@property (nonatomic,strong)RACSubject * requestSignal;

@property (nonatomic)NSInteger  bottomIndex;

/// 上次请求数据定位点，超过一定范围，再去请求
@property (nonatomic)CLLocationCoordinate2D lastRequestCorrdinate;
/// 是否自动滑动地图
@property (nonatomic)BOOL isAutoRegionChanging;
@property (nonatomic) BOOL isFirstLoad;

@end

@implementation NearbyShopsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    [self setupMapView];
    [self setupLocationMe];
    
    if (gMapHelper.coordinate.latitude != 0 || gMapHelper.coordinate.longitude != 0)
    {
        [self setCenter:gMapHelper.coordinate];
    }
    
    [self setupSYViewInContainer:self.bottomScrollView];
    //    [self.bottomSYView reloadData];
    
    self.mapView.showsUserLocation = YES;
    
    self.needRequestNearbyShop = YES;
    
    self.requestSignal = [RACSubject subject];
    @weakify(self)
    [self.requestSignal subscribeNext:^(MAMapView *mapView) {
        
        @strongify(self)
        CLLocationCoordinate2D coordinate = mapView.centerCoordinate;
        if ([DistanceCalcHelper getDistanceLatA:coordinate.latitude lngA:coordinate.longitude latB:self.lastRequestCorrdinate.latitude lngB:self.lastRequestCorrdinate.longitude] > RequestDistance)
        {
            if (self.searchType.integerValue == 1 || self.searchType.integerValue == 2 || self.searchType.integerValue == 3) {
                [self requestNearbyPlace:mapView.centerCoordinate andRange:2];
            } else {
                [self requestNearbyShops:mapView.centerCoordinate andRange:1];
            }
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mapView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.mapView.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"NearbyShopsViewController dealloc");
}

#pragma mark - UI
- (void)setupNavigationBar
{
    if (self.searchType.integerValue == 1) {
        self.navigationItem.title = @"附近停车场";
    } else if (self.searchType.integerValue == 2) {
        self.navigationItem.title = @"附近 4S 店";
    } else if (self.searchType.integerValue == 3) {
        self.navigationItem.title = @"附近加油站";
    } else {
        self.navigationItem.title = @"附近门店";
    }
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(returnAction)];
}

- (void)setupMapView
{
    @weakify(self);
    self.mapView.frame = self.view.bounds;
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self)
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}


- (void)setupSYViewInContainer:(UIView *)container
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = 95;
    SYPaginatorView *syView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    syView.clipsToBounds = NO;
    syView.pageControl.hidden = YES;
    syView.delegate = self;
    syView.dataSource = self;
    syView.pageGapWidth = 1;
    syView.backgroundColor = [UIColor clearColor];
    [container addSubview:syView];
    self.bottomSYView = syView;
    [syView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(container).offset(16);
        make.right.equalTo(container).offset(-16);
        make.top.equalTo(container).with.offset(5);
        make.height.mas_equalTo(height);
    }];
    self.bottomSYView.currentPageIndex = 0;
}

- (void)setupLocationMe
{
    @weakify(self)
    [[self.locationMeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp104_6"];
        @strongify(self)
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    }];
}


#pragma mark - Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadBottomView
{
    [self.bottomSYView reloadDataRemovingCurrentPage:YES];
    self.bottomSYView.currentPageIndex = self.bottomIndex;
}


#pragma mark - Utility
- (void)requestNearbyShops:(CLLocationCoordinate2D)coordinate andRange:(NSInteger)range
{
    self.lastRequestCorrdinate = coordinate;
    
    GetShopByRangeV2Op * op = [GetShopByRangeV2Op operation];
    op.longitude = coordinate.longitude;
    op.latitude = coordinate.latitude;
    op.range = range;
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetShopByRangeV2Op * op) {
        
        if (op.rsp_code == 0)
        {
            self.nearbyShopArray = [op.rsp_shopArray sortedArrayUsingComparator:^NSComparisonResult(JTShop * obj1, JTShop * obj2) {
                
                double distance1 = [DistanceCalcHelper getDistanceLatA:self.userCoordinate.latitude lngA:self.userCoordinate.longitude latB:obj1.shopLatitude lngB:obj1.shopLongitude];
                double distance2 = [DistanceCalcHelper getDistanceLatA:self.userCoordinate.latitude lngA:self.userCoordinate.longitude latB:obj2.shopLatitude lngB:obj2.shopLongitude];
                return distance1 > distance2;
            }];
            [self highlightMapViewWithIndex:0];
            [self.bottomSYView reloadData];
            //            if (self.nearbyShopArray.count)
            //            {
            //                JTShop * shop = [self.nearbyShopArray firstObject];
            //                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude);
            //                [self setCenter:coordinate];
            //            }
            self.bottomSYView.currentPageIndex = 0;
        }
    } error:^(NSError *error) {
        
        
    }];
}

- (void)requestNearbyPlace:(CLLocationCoordinate2D)coordinate andRange:(NSInteger)range
{
    self.lastRequestCorrdinate = coordinate;
    
    GetParkingShopGasInfoOp * op = [GetParkingShopGasInfoOp operation];
    NSNumberFormatter *format = [[NSNumberFormatter alloc] init];
    [format setPositiveFormat:@"0.######"];
    op.longitude = [format numberFromString:[NSString stringWithFormat:@"%f", coordinate.longitude]];
    op.latitude = [format numberFromString:[NSString stringWithFormat:@"%f", coordinate.latitude]];
    op.range = @(range);
    op.searchType = self.searchType;
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetParkingShopGasInfoOp * op) {
        
        if (op.rsp_code == 0)
        {
            NSNumber *shopID = @(1);
            NSArray *dataArray = op.extShops;
            NSMutableArray *distanceArray = [[NSMutableArray alloc] init];
            NSMutableArray *nearByPlaceDataSource = [[NSMutableArray alloc] init];
            for (NSDictionary *dict in dataArray) {
                NSArray *callNumberArray = dict[@"contactphones"];
                NSNumber *distanceNum = dict[@"distance"];
                JTShop *shop = [[JTShop alloc] init];
                shop.shopName = dict[@"name"];
                shop.shopID = shopID;
                shop.shopLongitude = [dict[@"longitude"] doubleValue];
                shop.shopLatitude = [dict[@"latitude"] doubleValue];
                shop.shopAddress = dict[@"address"];
                // 作为电话的 Array
                shop.customArray = [callNumberArray mutableCopy];
                [nearByPlaceDataSource addObject:shop];
                [distanceArray addObject:distanceNum];
                shopID = @(shopID.integerValue + 1);
            }
            self.nearbyShopArray = nearByPlaceDataSource;
            [self highlightMapViewWithIndex:0];
            [self.bottomSYView reloadData];
            self.bottomSYView.currentPageIndex = 0;
            //            if (self.nearbyShopArray.count)
            //            {
            //                JTShop * shop = [self.nearbyShopArray firstObject];
            //                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude);
            //                [self setCenter:coordinate];
            //            }
            if (self.isFirstLoad == NO) {
                NSNumber *distance = [distanceArray firstObject];
                double plottingValue = distance.doubleValue / 27;
                MACoordinateSpan span = MACoordinateSpanMake(plottingValue, plottingValue);
                MACoordinateRegion region = MACoordinateRegionMake(_mapView.centerCoordinate, span);
                _mapView.region = region;
            }
            
            self.isFirstLoad = YES;
        }
    } error:^(NSError *error) {
        
        
    }];
}

- (void)setCenter:(CLLocationCoordinate2D)co
{
    [self.mapView setZoomLevel:MapZoomLevel animated:YES];
    [self.mapView setCenterCoordinate:co animated:YES];
}

- (void)highlightMapViewWithIndex:(NSInteger)index
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (NSInteger  i = 0; i < self.nearbyShopArray.count; i++)
    {
        JTShop * shop = [self.nearbyShopArray safetyObjectAtIndex:i];
        MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
        destinationAnnotation.coordinate = CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude);
        destinationAnnotation.title = shop.shopName;
        destinationAnnotation.customObject = shop;
        
        destinationAnnotation.customTag = index == i ? 1 : 0;
        
        [self.mapView addAnnotation:destinationAnnotation];
    }
    
    
    //        JTShop * shop = [self.nearbyShopArray safetyObjectAtIndex:index];
    //        for (MAAnnotationView * v in  self.mapView.annotations)
    //        {
    //            v.image = [UIImage imageNamed:@"shop_pin"];
    //            if ([v.customObject isKindOfClass:[JTShop class]])
    //            {
    //                JTShop * s  = (JTShop *)v.customObject;
    //                if ([shop.shopID isEqualToString:s.shopID])
    //                {
    //                    v.image = [UIImage imageNamed:@"high_shop_pin"];
    //                }
    //                else
    //                {
    //                    v.image = [UIImage imageNamed:@"shop_pin"];
    //                }
    //            }x
    //        }
}

#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"navigationCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        MAPointAnnotation *pointAnnotation = (MAPointAnnotation *)annotation;
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:navigationCellIdentifier];
        }
        
        poiAnnotationView.canShowCallout = YES;
        if (self.searchType.integerValue == 1) {
            poiAnnotationView.image = pointAnnotation.customTag ? [UIImage imageNamed:@"nb_highlightedParkingLot"] : [UIImage imageNamed:@"nb_parkingLot"];
        } else if (self.searchType.integerValue == 2) {
            poiAnnotationView.image = pointAnnotation.customTag ? [UIImage imageNamed:@"nb_highlighted4sShop"] : [UIImage imageNamed:@"nb_4sShop"];
        } else if (self.searchType.integerValue == 3) {
            poiAnnotationView.image = pointAnnotation.customTag ? [UIImage imageNamed:@"nb_highlightedGasStation"] : [UIImage imageNamed:@"nb_gasStation"];
        } else {
            poiAnnotationView.image = pointAnnotation.customTag ? [UIImage imageNamed:@"high_shop_pin"] : [UIImage imageNamed:@"shop_pin"];
        }
        if (pointAnnotation.customTag)
        {
            poiAnnotationView.centerOffset = CGPointMake(0, -30);
        }
        else
        {
            poiAnnotationView.centerOffset = CGPointMake(0, -22);
        }
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    self.userCoordinate = userLocation.coordinate;
    gMapHelper.coordinate = userLocation.coordinate;
    if (self.needRequestNearbyShop)
    {
        if (self.searchType.integerValue == 1 || self.searchType.integerValue == 2 || self.searchType.integerValue == 3) {
            [self requestNearbyPlace:self.userCoordinate andRange:2];
            [self setCenter:self.userCoordinate];
            self.needRequestNearbyShop = NO;
        } else {
            [self requestNearbyShops:self.userCoordinate andRange:1];
            [self setCenter:self.userCoordinate];
            self.needRequestNearbyShop = NO;
        }
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    [MobClick event:@"rp104_1"];
    if ([view.annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAPointAnnotation * annotation = (MAPointAnnotation *)view.annotation;
        if ([annotation.customObject isKindOfClass:[JTShop class]])
        {
            JTShop * shop  = (JTShop *)annotation.customObject;
            
            for (NSInteger i = 0 ; i < self.nearbyShopArray.count; i++)
            {
                JTShop * s = [self.nearbyShopArray safetyObjectAtIndex:i];
                if ([shop.shopID isEqualToNumber:s.shopID])
                {
                    [self highlightMapViewWithIndex:i];
                    
                    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude);
                    [self.mapView setCenterCoordinate:coordinate animated:YES];
                    [self.bottomSYView setCurrentPageIndex:i animated:YES];
                    self.isAutoRegionChanging = YES;
                    return;
                }
            }
        }
    }
}

//地图滑动事件用willchange还是didchange,另,第一次进入以及定位当前也有滑动事件？  LYW
//- (void)mapView:(MAMapView *)mapView regionWillChangeAnimated:(BOOL)animated
//{
//    if (!self.isAutoRegionChanging)
//    {
//        [MobClick event:@"rp104-7"];
//    }
//    self.isAutoRegionChanging = NO;
//}
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!self.isAutoRegionChanging)
    {
        //包括放大操作
        [MobClick event:@"rp104_7"];
        [self.requestSignal sendNext:mapView];
    }
    self.isAutoRegionChanging = NO;
}

#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return self.nearbyShopArray.count;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SYPageView *pageView = [paginatorView dequeueReusablePageWithIdentifier:@"pageView"];
    
    if (self.searchType.integerValue == 1 || self.searchType.integerValue == 2 || self.searchType.integerValue == 3) {
        MapBottomV2View * mapBottomV2View;
        if (!pageView) {
            pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
            pageView.backgroundColor = [UIColor clearColor];
            
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MapBottomV2View" owner:self options:nil];
            MapBottomV2View *bottomView = nibArray[0];
            CGRect rect = pageView.bounds;
            rect.size.width = rect.size.width - 10;
            rect.origin.x = 5;
            bottomView.frame = rect;
            //        mapBottomView.autoresizingMask = UIViewAutoresizingFlexibleAll;
            bottomView.tag = 1001;
            bottomView.backgroundColor = [UIColor whiteColor];
            bottomView.borderWidth = 0.5f;
            bottomView.layer.borderColor = kLightLineColor.CGColor;
            bottomView.layer.cornerRadius = 5.0f;
            
            [pageView addSubview:bottomView];
        }
        
        mapBottomV2View = (MapBottomV2View *)[pageView searchViewWithTag:1001];
        if (!mapBottomV2View)
        {
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MapBottomView" owner:self options:nil];
            mapBottomV2View = nibArray[0];
            CGRect rect = pageView.bounds;
            rect.size.width = rect.size.width - 10;
            rect.origin.x = 5;
            mapBottomV2View.frame = rect;
            //        mapBottomView.autoresizingMask = UIViewAutoresizingFlexibleAll;
            mapBottomV2View.tag = 1001;
            mapBottomV2View.backgroundColor = [UIColor whiteColor];
            mapBottomV2View.borderWidth = 1.0f;
            mapBottomV2View.layer.borderColor = [UIColor lightGrayColor].CGColor;
            mapBottomV2View.layer.cornerRadius = 5.0f;
            
            [pageView addSubview:mapBottomV2View];
        }
        
        
        JTShop * shop = [self.nearbyShopArray safetyObjectAtIndex:pageIndex];
        
        mapBottomV2View.titleLabel.text = shop.shopName;
        mapBottomV2View.addressLabel.text = shop.shopAddress;
        
        if (shop.customArray.count == 0) {
            mapBottomV2View.callButton.enabled = NO;
        } else {
            mapBottomV2View.callButton.enabled = YES;
        }
        
        [[[mapBottomV2View.callButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
            [MobClick event:@"rp104_4"];
            
            UIActionSheet *callSheet = [[UIActionSheet alloc] initWithTitle:@"请选择需要拨打的电话" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:nil, nil];
            for (NSString *number in shop.customArray) {
                [callSheet addButtonWithTitle:number];
            }
            [callSheet showInView:self.view];
            
            [[callSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber *number) {
                NSInteger buttonIndex = [number integerValue];
                shop.shopPhone = [callSheet buttonTitleAtIndex:buttonIndex];
                [gPhoneHelper makePhone:shop.shopPhone andInfo:shop.shopPhone];
            }];
        }];
        
        @weakify(self);
        [[[mapBottomV2View.navigationButton rac_signalForControlEvents:UIControlEventTouchUpInside]  takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
            
            @strongify(self)
            [MobClick event:@"rp104_5"];
            [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.userCoordinate andView:self.view];
        }];
        
    } else {
        
        MapBottomView * mapBottomView;
        if (!pageView) {
            pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
            pageView.backgroundColor = [UIColor clearColor];
            
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MapBottomView" owner:self options:nil];
            MapBottomView *bottomView = nibArray[0];
            CGRect rect = pageView.bounds;
            rect.size.width = rect.size.width - 10;
            rect.origin.x = 5;
            bottomView.frame = rect;
            //        mapBottomView.autoresizingMask = UIViewAutoresizingFlexibleAll;
            bottomView.tag = 1001;
            bottomView.backgroundColor = [UIColor whiteColor];
            bottomView.borderWidth = 0.5f;
            bottomView.layer.borderColor = kLightLineColor.CGColor;
            bottomView.layer.cornerRadius = 5.0f;
            
            [pageView addSubview:bottomView];
        }
        
        mapBottomView = (MapBottomView *)[pageView searchViewWithTag:1001];
        if (!mapBottomView)
        {
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MapBottomView" owner:self options:nil];
            mapBottomView = nibArray[0];
            CGRect rect = pageView.bounds;
            rect.size.width = rect.size.width - 10;
            rect.origin.x = 5;
            mapBottomView.frame = rect;
            //        mapBottomView.autoresizingMask = UIViewAutoresizingFlexibleAll;
            mapBottomView.tag = 1001;
            mapBottomView.backgroundColor = [UIColor whiteColor];
            mapBottomView.borderWidth = 1.0f;
            mapBottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            mapBottomView.layer.cornerRadius = 5.0f;
            
            [pageView addSubview:mapBottomView];
        }
        
        
        JTShop * shop = [self.nearbyShopArray safetyObjectAtIndex:pageIndex];
        
        BOOL favorite = [gAppMgr.myUser.favorites getFavoriteWithID:shop.shopID] ? YES : NO;
        UIImage * image = [UIImage imageNamed:favorite ? @"nb_collected_300" : @"nb_collection_300"];
        [mapBottomView.collectBtn setImage:image forState:UIControlStateNormal];
        
        
        mapBottomView.titleLb.text = shop.shopName;
        mapBottomView.addressLb.text = shop.shopAddress;
        
        @weakify(self)
        [[[mapBottomView.detailBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
            
            [MobClick event:@"rp104_2"];
            ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
            vc.shop = shop;
            
            @strongify(self)
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
        [[[mapBottomView.phoneBtm rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
            
            [MobClick event:@"rp104_4"];
            if (shop.shopPhone.length == 0)
            {
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"好吧" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
                if (self.searchType.integerValue == 1) {
                    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该停车场没有电话~" ActionItems:@[cancel]];
                    [alert show];
                } else if (self.searchType.integerValue == 2) {
                    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该 4S 店没有电话~" ActionItems:@[cancel]];
                    [alert show];
                } else if (self.searchType.integerValue == 3) {
                    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该加油站没有电话~" ActionItems:@[cancel]];
                    [alert show];
                } else {
                    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该店铺没有电话~" ActionItems:@[cancel]];
                    [alert show];
                }
                return ;
            }
            
            NSString * info = [NSString stringWithFormat:@"%@",shop.shopPhone];
            [gPhoneHelper makePhone:shop.shopPhone andInfo:info];
        }];
        
        [[[mapBottomView.collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
            
            [MobClick event:@"rp104_3"];
            @strongify(self)
            if ([LoginViewModel loginIfNeededForTargetViewController:self])
            {
                CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
                k.values = @[@(0.1),@(1.0),@(1.5)];
                k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
                k.calculationMode = kCAAnimationLinear;
                [mapBottomView.collectBtn.imageView.layer addAnimation:k forKey:@"SHOW"];
                
                if ([gAppMgr.myUser.favorites getFavoriteWithID:shop.shopID])
                {
                    [[[[gAppMgr.myUser.favorites rac_removeFavorite:@[shop.shopID]] initially:^{
                        
                        [gToast showingWithText:@"移除中..."];
                    }] finally:^{
                        
                        [gToast dismiss];
                    }] subscribeNext:^(id x) {
                        
                        [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collection"] forState:UIControlStateNormal];
                    } error:^(NSError *error) {
                        
                        [gToast showError:error.domain];
                    }];
                }
                else
                {
                    [[[[gAppMgr.myUser.favorites rac_addFavorite:shop] initially:^{
                        
                        [gToast showingWithText:@"添加中..."];
                    }] finally:^{
                        
                        [gToast dismiss];
                    }] subscribeNext:^(id x) {
                        
                        [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collected_300"] forState:UIControlStateNormal];
                    } error:^(NSError *error) {
                        
                        if (error.code == 7002)
                        {
                            [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collected_300"] forState:UIControlStateNormal];
                        }
                        else
                        {
                            [gToast showError:error.domain];
                        }
                    }];
                }
            }
        }];
        
        [[[mapBottomView.navigationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]  takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
            
            @strongify(self)
            [MobClick event:@"rp104_5"];
            [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.userCoordinate andView:self.view];
        }];
    }
    
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    [MobClick event:@"rp104_8"];
    self.bottomIndex = pageIndex;
    self.isAutoRegionChanging = YES;
    [self highlightMapViewWithIndex:pageIndex];
    
    JTShop * shop = [self.nearbyShopArray safetyObjectAtIndex:pageIndex];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}



@end
