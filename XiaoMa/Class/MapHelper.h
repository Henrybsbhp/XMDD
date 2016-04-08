//
//  MapHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import <MAMapKit/MAMapKit.h>
#import "XiaoMa.h"
#import "HKAddressComponent.h"

//#define AMapKey @"0442b54d277405a2f29a42f773a137aa" //cn.jtang.xmdd
@interface MapHelper : NSObject<MAMapViewDelegate,AMapSearchDelegate>

+ (MapHelper *)sharedHelper;

- (void)setupMapApi;

- (void)setupMAMap;

@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) MAMapView *mapView;

/// 当前位置
@property (nonatomic)CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) HKAddressComponent *addrComponent;

- (void)startLocation;

- (void)stopLocation;

- (RACSignal *)rac_getUserLocation;
- (RACSignal *)rac_getInvertGeoInfo;

- (void)handleGPSError:(NSError *)error;

@end

