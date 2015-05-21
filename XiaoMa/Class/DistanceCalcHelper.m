//
//  DistanceCalcHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DistanceCalcHelper.h"
#import <CoreLocation/CLLocation.h>
#import <UIKit/UIKit.h>

@implementation DistanceCalcHelper

#define EARTH_RADIUS 6378.137;//地球半径

+ (double)getDistanceLatA:(double)latA
                     lngA:(double)lngA
                     latB:(double)latB
                     lngB:(double)lngB
{
    
    CLLocation *orig= [[CLLocation alloc] initWithLatitude:latA  longitude:lngA];
    CLLocation* dist= [[CLLocation alloc] initWithLatitude:latB longitude:lngB];
    
    CLLocationDistance meters = [orig distanceFromLocation:dist];
    return meters;
}


+ (NSString *)getDistanceStrLatA:(double)latA
                         lngA:(double)lngA
                         latB:(double)latB
                         lngB:(double)lngB
{
    NSString * distanceStr;
    double distance = [DistanceCalcHelper getDistanceLatA:latA lngA:lngA latB:latB lngB:lngB];
//    if (distance < 1000)
//    {
//        distanceStr = [NSString stringWithFormat:@"%ld米",(long)distance];
//    }
//    else
    {
        CGFloat distanceInt = distance / 1000;
        distanceStr = [NSString stringWithFormat:@"%0.2fkm",distanceInt];
    }
    return distanceStr;
}

@end
