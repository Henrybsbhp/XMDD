//
//  NearbyShopsViewController.m
//  XiaoMa
//
//  Created by jt on 15-4-22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "NearbyShopsViewController.h"
#import "GetShopByRangeOp.h"
#import "JTShop.h"
#import "MapBottomView.h"
#import "ShopDetailVC.h"
#import "SYPaginator.h"
#import "AddUserFavoriteOp.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DistanceCalcHelper.h"

/// 超过2km
#define RequestDistance 2000

@interface NearbyShopsViewController ()<UIActionSheetDelegate,SYPaginatorViewDataSource, SYPaginatorViewDelegate>

@property (weak, nonatomic) IBOutlet MAMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *bottomScrollView;
@property (weak, nonatomic) IBOutlet UIButton *locationMeBtn;

@property (nonatomic, strong) SYPaginatorView *bottomSYView;

@property (nonatomic)CLLocationCoordinate2D userCoordinate;
@property (nonatomic)BOOL needRequestNearbyShop;

@property (nonatomic,strong)NSArray * nearbyShopArray;

@property (nonatomic,strong)RACSubject * requestSignal;

/// 上次请求数据定位点，超过一定范围，再去请求
@property (nonatomic)CLLocationCoordinate2D lastRequestCorrdinate;
/// 是否自动滑动地图
@property (nonatomic)BOOL isAutoRegionChanging;

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
    [self.bottomSYView reloadData];
    
    self.mapView.showsUserLocation = YES;
    
    self.needRequestNearbyShop = YES;
    
    self.requestSignal = [RACSubject subject];
    @weakify(self)
    [self.requestSignal subscribeNext:^(MAMapView *mapView) {
        
        @strongify(self)
        CLLocationCoordinate2D coordinate = mapView.centerCoordinate;
        if ([DistanceCalcHelper getDistanceLatA:coordinate.latitude lngA:coordinate.longitude latB:self.lastRequestCorrdinate.latitude lngB:self.lastRequestCorrdinate.longitude] > RequestDistance)
        {
            [self requestNearbyShops:mapView.centerCoordinate andRange:1];
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
    self.navigationItem.title = @"附近门店";
    
    UIImage *img = [UIImage imageNamed:@"cm_nav_back"];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStylePlain
                                                            target:self action:@selector(returnAction)];
    [self.navigationItem setLeftBarButtonItem:item animated:YES];
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
       
        @strongify(self)
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    }];
}


#pragma mark - Action

- (void)returnAction
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark - Utility
- (void)requestNearbyShops:(CLLocationCoordinate2D)coordinate andRange:(NSInteger)range
{
    self.lastRequestCorrdinate = coordinate;
    
    GetShopByRangeOp * op = [GetShopByRangeOp operation];
    op.longitude = coordinate.longitude;
    op.latitude = coordinate.latitude;
    op.range = range;
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetShopByRangeOp * op) {
        
        if (op.rsp_code == 0)
        {
            self.nearbyShopArray = op.rsp_shopArray;
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
//            }
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
        poiAnnotationView.image = pointAnnotation.customTag ? [UIImage imageNamed:@"high_shop_pin"] : [UIImage imageNamed:@"shop_pin"];
        
        
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
        [self requestNearbyShops:self.userCoordinate andRange:1];
        [self setCenter:self.userCoordinate];
        self.needRequestNearbyShop = NO;
    }
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
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

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!self.isAutoRegionChanging)
    {
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
        bottomView.borderWidth = 1.0f;
        bottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
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
    UIImage * image = [UIImage imageNamed:favorite ? @"nb_collected" : @"nb_collection"];
    [mapBottomView.collectBtn setImage:image forState:UIControlStateNormal];

    
    mapBottomView.titleLb.text = shop.shopName;
    mapBottomView.addressLb.text = shop.shopAddress;
    
    @weakify(self)
    [[[mapBottomView.detailBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
        vc.shop = shop;
        
        @strongify(self)
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[[mapBottomView.phoneBtm rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        if (shop.shopPhone.length == 0)
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:@"该店铺没有电话~" delegate:nil cancelButtonTitle:@"好吧" otherButtonTitles:nil];
            [av show];
            return ;
        }
        
        NSString * info = [NSString stringWithFormat:@"%@",shop.shopPhone];
        [gPhoneHelper makePhone:shop.shopPhone andInfo:info];
    }];
    
    [[[mapBottomView.collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        @strongify(self)
        if ([LoginViewModel loginIfNeededForTargetViewController:self])
        {
            if ([gAppMgr.myUser.favorites getFavoriteWithID:shop.shopID])
            {
                [[[gAppMgr.myUser.favorites rac_removeFavorite:@[shop.shopID]] initially:^{
                    
                    [SVProgressHUD showWithStatus:@"移除中..."];
                }]  subscribeNext:^(id x) {
                    
                    [SVProgressHUD showSuccessWithStatus:@"移除成功"];
                    
                    [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collection"] forState:UIControlStateNormal];
                } error:^(NSError *error) {
                    
                    [SVProgressHUD showErrorWithStatus:error.domain];
                }];
            }
            else
            {
                [[[gAppMgr.myUser.favorites rac_addFavorite:shop] initially:^{
                    
                    [SVProgressHUD showWithStatus:@"添加中..."];
                }]  subscribeNext:^(id x) {
                    
                    [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                    
                    [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collected"] forState:UIControlStateNormal];
                } error:^(NSError *error) {
                    
                    if (error.code == 7002)
                    {
                        [SVProgressHUD showSuccessWithStatus:@"添加成功"];
                        [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collected"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [SVProgressHUD showErrorWithStatus:error.domain];
                    }
                }];
            }
        }
    }];
    
    [[[mapBottomView.navigationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]  takeUntil:[pageView rac_signalForSelector:@selector(prepareForReuse)]] subscribeNext:^(id x) {
        
        @strongify(self)
        
        [gPhoneHelper navigationRedirectThirdMap:shop andUserLocation:self.userCoordinate andView:self.view];
    }];

    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
    self.isAutoRegionChanging = YES;
    [self highlightMapViewWithIndex:pageIndex];

    JTShop * shop = [self.nearbyShopArray safetyObjectAtIndex:pageIndex];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude);
    [self.mapView setCenterCoordinate:coordinate animated:YES];
}



@end
