//
//  DistanceCalcHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface DistanceCalcHelper : NSObject

+ (double)getDistanceLatA:(double)latA
                     lngA:(double)lngA
                     latB:(double)latB
                     lngB:(double)lngB;


+ (NSString *)getDistanceStrLatA:(double)latA
                            lngA:(double)lngA
                            latB:(double)latB
                            lngB:(double)lngB;

/// 将火星坐标系转换为百度坐标系
+ (CLLocationCoordinate2D)GCJ2BAIDU:(CLLocationCoordinate2D)amapCoordinate;

@end
