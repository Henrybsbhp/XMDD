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

#define AMapKey @"8b0b664d2df333201514aacb8e1551bc"

@interface MapHelper : NSObject<MAMapViewDelegate,AMapSearchDelegate>

+ (MapHelper *)sharedHelper;

- (void)setupMapApi;

- (void)setupMAMap;

@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) MAMapView *mapView;

/// 当前位置
@property (nonatomic)CLLocationCoordinate2D coordinate;

@property (nonatomic,copy)NSString * province;
@property (nonatomic,copy)NSString * city;
@property (nonatomic,copy)NSString * district;

/// 定位结果信号
@property (nonatomic, strong)RACSubject * rac_userLocationResultSignal;
/// 反地理编码结果信号
@property (nonatomic, strong)RACSubject * rac_invertGeoResultSignal;

- (void)startLocation;

- (void)stopLocation;

- (RACSignal *)rac_getInvertGeoInfo;

@end
