//
//  MapHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "Xmdd.h"
#import "GetAreaByPcdOp.h"

@interface MapHelper : NSObject<AMapLocationManagerDelegate,AMapSearchDelegate>

+ (MapHelper *)sharedHelper;

- (void)setupMapApi;

/// 当前位置
@property (nonatomic)CLLocationCoordinate2D coordinate;
/// 当前反地理位置编码的signal
@property (nonatomic, strong) RACSignal *currentReGeocodeSignal;
///有值说明定位成功
@property (nonatomic, strong)HKAddressComponent *addrComponent;

///得到用户当前经纬度位置（return : RACTuplePack(CLLocation)）
- (RACSignal *)rac_getUserLocationWithAccuracy:(CLLocationAccuracy)accuracy;
///得到用户当前经纬度位置 及 地理位置信息信号 （return : RACTuplePack(CLLocation,AMapLocationReGeocode)）
- (RACSignal *)rac_getUserLocationAndInvertGeoInfoWithAccuracy:(CLLocationAccuracy)accuracy;
///得到用户城市信息code（return : GetAreaByPcdOp)）
- (RACSignal *)rac_getAreaInfo;
/// 反地理位置编码，如果self.currentReGeocodeSignal存在直接返回，否则重新定位并获取反地理位置编码
- (RACSignal *)rac_getReGeocodeIfNeededWithAccuracy:(CLLocationAccuracy)accuracy;

- (void)handleGPSError:(NSError *)error;

@end

