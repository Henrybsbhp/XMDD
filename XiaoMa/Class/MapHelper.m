//
//  MapHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MapHelper.h"
#import "HKMapView.h"

@interface MapHelper()

@property (nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation MapHelper


+ (MapHelper *)sharedHelper
{
    static dispatch_once_t onceToken;
    static MapHelper *g_mapManager;
    dispatch_once(&onceToken, ^{
        g_mapManager = [[MapHelper alloc] init];
    });
    return g_mapManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
//        [self fetchAddressComponetDict];
    }
    return self;
}

- (void)setupMapApi
{
    [MAMapServices sharedServices].apiKey = AMAP_API_ID;
    self.searchApi = [[AMapSearchAPI alloc] initWithSearchKey:AMAP_API_ID Delegate:self];
}

- (void)setupMAMap
{
    self.mapView = [[HKMapView alloc] initWithFrame:CGRectZero];
    self.mapView.delegate = self;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)startLocation
{
    self.mapView.showsUserLocation = YES;
//    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}

- (void)stopLocation
{
    self.mapView.showsUserLocation = NO;
//    self.mapView.userTrackingMode = MAUserTrackingModeNone;
}

- (void)invertGeo:(CLLocationCoordinate2D)coordiate
{
    AMapReGeocodeSearchRequest * regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:coordiate.latitude longitude:coordiate.longitude];
    
    [self.searchApi AMapReGoecodeSearch:regeo];
}

- (RACSignal *)rac_getUserLocation
{
    RACSignal *updateSig = [[self rac_signalForSelector:@selector(mapView:didUpdateUserLocation:)
                                           fromProtocol:@protocol(MAMapViewDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
    RACSignal *errorSig = [[self rac_signalForSelector:@selector(mapView:didFailToLocateUserWithError:)
                                          fromProtocol:@protocol(MAMapViewDelegate)] flattenMap:^RACStream *(RACTuple *tuple) {
        return [RACSignal error:tuple.second];
    }];
    return [[[[[updateSig merge:errorSig] take:1] initially:^{
        [self startLocation];
    }] finally:^{
        [self stopLocation];
    }] doNext:^(MAUserLocation * l) {
        
        self.coordinate = l.coordinate;
    }];
}

- (RACSignal *)rac_getInvertGeoInfo
{
    RACSignal * signal = [self rac_getUserLocation];
    
    signal = [signal flattenMap:^RACStream *(MAUserLocation *userLocation) {

        RACSignal *geoSig = [[self rac_signalForSelector:@selector(onReGeocodeSearchDone:response:)
                                           fromProtocol:@protocol(AMapSearchDelegate)] map:^id(RACTuple *tuple) {
            AMapReGeocodeSearchResponse * rsp = tuple.second;
            return rsp.regeocode;
        }];
        RACSignal *errSig = [[self rac_signalForSelector:@selector(searchRequest:didFailWithError:) fromProtocol:@protocol(AMapSearchDelegate)] flattenMap:^RACStream *(RACTuple *tuple) {
            return [RACSignal error:tuple.second];
        }];
        [self invertGeo:userLocation.location.coordinate];
        return [[geoSig merge:errSig] take:1];
    }];
    return signal;
}

#pragma mark - MAMapViewDelegate
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
}

#pragma mark - AMapSearchDelegate
- (void)searchRequest:(id)request didFailWithError:(NSError *)error
{
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    AMapReGeocode * regeoCode = response.regeocode;
    if (regeoCode) {
        [self saveAddressComponent:regeoCode.addressComponent];
    }
}

#pragma mark - Utility
- (void)saveAddressComponent:(AMapAddressComponent *)componet
{
    HKAddressComponent *hkcomponent = [HKAddressComponent addressComponentWith:componet];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:hkcomponent];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"HKAddressComponent"];
    self.addrComponent = hkcomponent;
}

- (void)fetchAddressComponetDict
{
     NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"HKAddressComponent"];
    if (data) {
        self.addrComponent = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

- (void)handleGPSError:(NSError *)error
{
    switch (error.code) {
        case kCLErrorDenied:
        {
            if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开,然后刷新页面" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"前往设置", nil];
                
                [[av rac_buttonClickedSignal] subscribeNext:^(id x) {
                    
                    if ([x integerValue] == 1)
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }
                }];
                [av show];
            }
            else
            {
                UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"您没有打开定位服务,请前往设置打开，然后刷新页面" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles: nil];
                
                [av show];
            }
            break;
        }
        case LocationFail:
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"城市定位失败,请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            
            [av show];
        }
        default:
        {
            UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"" message:@"定位失败，请重试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            
            [av show];
            break;
        }
    }
}

@end

