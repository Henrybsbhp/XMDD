//
//  MapHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MapHelper.h"

#define AMapKey @"8b0b664d2df333201514aacb8e1551bc"

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

- (void)setupMapApi
{
    [MAMapServices sharedServices].apiKey = AMapKey;
    self.searchApi = [[AMapSearchAPI alloc] initWithSearchKey:AMapKey Delegate:nil];
}

- (void)setupMAMap
{
    self.mapView = [[MAMapView alloc] init];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestAlwaysAuthorization];
    }
}

@end
