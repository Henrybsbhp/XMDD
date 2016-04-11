//
//  CarWashNavigationViewController.m
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarWashNavigationViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapBottomView.h"
#import "ShopDetailVC.h"
#import "AddUserFavoriteOp.h"


@interface CarWashNavigationViewController ()<UIActionSheetDelegate>

@property (nonatomic)CLLocationCoordinate2D startCoordinate;
@property (nonatomic)CLLocationCoordinate2D endCoordinate;

@property (strong, nonatomic) UIButton *locationMeBtn;

@end

@implementation CarWashNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.shop.shopName;
    
    self.endCoordinate = CLLocationCoordinate2DMake(self.shop.shopLatitude, self.shop.shopLongitude);
    
    CKAsyncMainQueue(^{
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        
        [self setCenter:self.endCoordinate];
        [self addDefaultAnnotations];
        [self setupBottomView];
        [self setupLocationMe];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"CarWashNavigationViewController dealloc");
}



#pragma mark - Setup UI
- (void)setupBottomView
{
    NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MapBottomView" owner:self options:nil];
    MapBottomView *mapBottomView = nibArray[0];
    CGRect rect = CGRectMake(5, self.view.frame.size.height - 100, self.view.frame.size.width - 10, 95);
    rect.size.width = rect.size.width;
    rect.origin.x = 5;
    mapBottomView.frame = rect;
    //        mapBottomView.autoresizingMask = UIViewAutoresizingFlexibleAll;
    mapBottomView.tag = 1001;
    mapBottomView.backgroundColor = [UIColor whiteColor];
    mapBottomView.borderWidth = 1.0f;
    mapBottomView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    mapBottomView.layer.cornerRadius = 5.0f;
    
    mapBottomView.titleLb.text = self.shop.shopName;
    mapBottomView.addressLb.text = self.shop.shopAddress;
    mapBottomView.detailBtn.hidden = YES;
    
    
    [mapBottomView.titleLb mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(mapBottomView).offset(-20);
    }];
    
    [mapBottomView.addressLb mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.width.equalTo(mapBottomView).offset(-20);
    }];
    
    UIImage * image = [UIImage imageNamed:self.favorite ? @"nb_collected" : @"nb_collection"];
    [mapBottomView.collectBtn setImage:image forState:UIControlStateNormal];
    
    @weakify(self)
    [[mapBottomView.detailBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
        vc.shop = self.shop;
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    [[mapBottomView.phoneBtm rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp104_4"];
        @strongify(self)
        if (self.shop.shopPhone.length == 0)
        {
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"好吧" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
            HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"" ImageName:@"mins_bulb" Message:@"该店铺没有电话~" ActionItems:@[cancel]];
            [alert show];
            
            return ;
        }
        
        NSString * info = [NSString stringWithFormat:@"%@",self.shop.shopPhone];
        [gPhoneHelper makePhone:self.shop.shopPhone andInfo:info];
    }];
    
    [[mapBottomView.collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp104_3"];
    
        @strongify(self)
        if ([LoginViewModel loginIfNeededForTargetViewController:self])
        {
            CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            k.values = @[@(0.1),@(1.0),@(1.5)];
            k.keyTimes = @[@(0.0),@(0.5),@(0.8),@(1.0)];
            k.calculationMode = kCAAnimationLinear;
            [mapBottomView.collectBtn.imageView.layer addAnimation:k forKey:@"SHOW"];
            
            if (self.favorite)
            {
                [[[[gAppMgr.myUser.favorites rac_removeFavorite:@[self.shop.shopID]] initially:^{
                    
                    [gToast showingWithText:@"移除中..."];
                }] finally:^{
                    
                    [gToast dismiss];
                }] subscribeNext:^(id x) {
                    

                    self.favorite = NO;
                    [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collection"] forState:UIControlStateNormal];
                } error:^(NSError *error) {
                    
                    [gToast showError:error.domain];
                }];
            }
            else
            {
                [[[[gAppMgr.myUser.favorites rac_addFavorite:self.shop] initially:^{
                    
                    [gToast showingWithText:@"添加中..."];
                }] finally:^{
                    
                    [gToast dismiss];
                }] subscribeNext:^(id x) {
                    
                    self.favorite = YES;
                    [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collected"] forState:UIControlStateNormal];
                } error:^(NSError *error) {
                    
                    if (error.code == 7002)
                    {
                        self.favorite = YES;
                        [mapBottomView.collectBtn setImage:[UIImage imageNamed:@"nb_collected"] forState:UIControlStateNormal];
                    }
                    else
                    {
                        [gToast showError:error.domain];
                    }
                }];
            }
        }
    }];
    
    [[mapBottomView.navigationBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp104_5"];
        @strongify(self)
        [gPhoneHelper navigationRedirectThirdMap:self.shop andUserLocation:self.startCoordinate andView:self.view];
        
    }];

    
    [self.view addSubview:mapBottomView];
}

- (void)addDefaultAnnotations
{
    MAPointAnnotation *destinationAnnotation = [[MAPointAnnotation alloc] init];
    destinationAnnotation.coordinate = CLLocationCoordinate2DMake(self.shop.shopLatitude, self.shop.shopLongitude);
    destinationAnnotation.title      = self.shop.shopName;
    destinationAnnotation.subtitle   = self.shop.shopAddress;
    
    [self.mapView addAnnotation:destinationAnnotation];
}

- (void)setCenter:(CLLocationCoordinate2D)co
{
    [self.mapView setZoomLevel:MapZoomLevel animated:YES];
    [self.mapView setCenterCoordinate:co animated:YES];
}

- (void)setupLocationMe
{
    CGRect rect = CGRectMake(5, self.view.frame.size.height - 100 - 30 - 5, 30, 30);
    self.locationMeBtn = [[UIButton alloc] initWithFrame:rect];
    [self.locationMeBtn setBackgroundImage:[UIImage imageNamed:@"location_me"] forState:UIControlStateNormal];
    [self.view addSubview:self.locationMeBtn];
    
    [MobClick event:@"rp104_6"];
    @weakify(self)
    [[self.locationMeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        [self.mapView setCenterCoordinate:self.mapView.userLocation.coordinate animated:YES];
    }];
}

#pragma mark - Utitily
#pragma mark - MAMapViewDelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *navigationCellIdentifier = @"navigationCellIdentifier";
        
        MAAnnotationView *poiAnnotationView = (MAAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:navigationCellIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:navigationCellIdentifier];
        }
        
        
        poiAnnotationView.canShowCallout = YES;
        
        poiAnnotationView.image = [UIImage imageNamed:@"high_shop_pin"];
        poiAnnotationView.centerOffset = CGPointMake(0, -30);
        
        return poiAnnotationView;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation;
{
    self.startCoordinate = userLocation.location.coordinate;
    gMapHelper.coordinate = userLocation.location.coordinate;
}

- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    [MobClick event:@"rp104_1"];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //包括放大操作
    [MobClick event:@"rp104_7"];
}

@end
