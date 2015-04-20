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

@interface MapHelper : NSObject

+ (MapHelper *)sharedHelper;

- (void)setupMapApi;

- (void)setupMAMap;

@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) MAMapView *mapView;

@end
