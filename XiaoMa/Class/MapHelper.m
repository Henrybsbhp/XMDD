//
//  MapHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MapHelper.h"

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
    if (self)
    {
        _rac_userLocationResultSignal = [RACSubject subject];
        _rac_invertGeoResultSignal = [RACSubject subject];
        [self fetchAddressComponetDict];
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
    self.mapView = [[MAMapView alloc] init];
    self.mapView.delegate = self;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        self.locationManager = [[CLLocationManager alloc] init];
//        [self.locationManager requestAlwaysAuthorization];
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
    RACSignal * signal;
    [self startLocation];
    signal = [self.rac_userLocationResultSignal map:^id(MAUserLocation *userLocation) {
        return userLocation;
    }];
    return signal;
}

- (RACSignal *)rac_getInvertGeoInfo
{
    RACSignal * signal;
    [self startLocation];
    signal = [self.rac_userLocationResultSignal map:^id(MAUserLocation *userLocation) {
        return userLocation;
    }];
    
    signal = [[[[signal flattenMap:^RACStream *(MAUserLocation *userLocation) {
        
        [self invertGeo:userLocation.coordinate];
        return self.rac_invertGeoResultSignal;
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }] flattenMap:^RACStream *(AMapReGeocode * regeoCode) {
        
        return [RACSignal return:regeoCode];
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
    
    return signal;
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
{
    self.coordinate = userLocation.coordinate;
    [self.rac_userLocationResultSignal sendNext:userLocation] ;
    [self stopLocation];
}

- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self.rac_userLocationResultSignal sendError:error];
    [self stopLocation];
}

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    AMapReGeocode * regeoCode = response.regeocode;
    if (regeoCode)
    {
        [self saveAddressComponent:regeoCode.addressComponent];
//        self.province = regeoCode.addressComponent.province;
//        self.city = regeoCode.addressComponent.city;
//        self.district = regeoCode.addressComponent.district;
        [self.rac_invertGeoResultSignal sendNext:regeoCode];
    }
    else
    {
        NSError *error = [NSError errorWithDomain:@"获取城市信息失败" code:LocationFail userInfo:nil];
        [self.rac_invertGeoResultSignal sendError:error];
    }
}


#pragma mark - Utility
- (void)saveAddressComponent:(AMapAddressComponent *)componet
{
    if (componet && (!self.addrComponent || ![self.addrComponent isEqualToAMapAddressComponent:componet])) {
        HKAddressComponent *hkcomponent = [HKAddressComponent addressComponentWith:componet];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:hkcomponent];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"HKAddressComponent"];
        self.addrComponent = hkcomponent;
    }
}

- (void)fetchAddressComponetDict
{
     NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"HKAddressComponent"];
    if (data) {
        self.addrComponent = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

@end

