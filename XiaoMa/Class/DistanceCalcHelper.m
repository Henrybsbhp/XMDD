//
//  DistanceCalcHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DistanceCalcHelper.h"
#import <math.h>

@implementation DistanceCalcHelper

#define EARTH_RADIUS 6378.137;//地球半径

+ (double)getDistanceLatA:(double)latA
                     lngA:(double)lngA
                     latB:(double)latB
                     lngB:(double)lngB
{
    
    double radLat1 =  [DistanceCalcHelper rad:latA];
    
    double radLat2 = [DistanceCalcHelper rad:latB];
    
    double a = radLat1 - radLat2;
    double b = [DistanceCalcHelper rad:lngA] - [DistanceCalcHelper rad:lngB];
    
    double s = 2 * sin(sqrt(pow(sin(a / 2), 2)
                            + cos(radLat1) * cos(radLat2)
                            * pow(sin(b / 2), 2)));
    s = s * EARTH_RADIUS;
    s = s*1000;
    double c = (round((s))/10)*10 /1000.0;
    
    return c;
}

+ (double)rad:(double)d
{
    return d * M_PI / 180.0;
}

+ (NSString *)getDistanceStrLatA:(double)latA
                         lngA:(double)lngA
                         latB:(double)latB
                         lngB:(double)lngB
{
    NSString * distanceStr;
    double distance = [DistanceCalcHelper getDistanceLatA:latA lngA:lngA latB:latB lngB:lngB];
    if (distance < 1000)
    {
        distanceStr = [NSString stringWithFormat:@"%ld米",(long)distance];
    }
    else
    {
        NSInteger distanceInt = distance / 1000;
        distanceStr = [NSString stringWithFormat:@"%ld千米",distanceInt];
    }
    return distanceStr;
}

@end
