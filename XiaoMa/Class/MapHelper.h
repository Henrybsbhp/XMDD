//
//  MapHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "XiaoMa.h"
#import "GetAreaByPcdOp.h"

@interface MapHelper : NSObject<AMapLocationManagerDelegate,AMapSearchDelegate>

+ (MapHelper *)sharedHelper;

- (void)setupMapApi;

/// 当前位置
@property (nonatomic)CLLocationCoordinate2D coordinate;

///有值说明定位成功
@property (nonatomic, strong)HKAddressComponent *addrComponent;

///得到用户当前经纬度位置（return : RACTuplePack(CLLocation)）
- (RACSignal *)rac_getUserLocationWithAccuracy:(CLLocationAccuracy)accuracy;
///得到用户当前经纬度位置 及 地理位置信息信号 （return : RACTuplePack(CLLocation,AMapLocationReGeocode)）
- (RACSignal *)rac_getUserLocationAndInvertGeoInfoWithAccuracy:(CLLocationAccuracy)accuracy;
///得到用户城市信息code（return : GetAreaByPcdOp)）
- (RACSignal *)rac_getAreaInfo;

- (void)handleGPSError:(NSError *)error;

@end

