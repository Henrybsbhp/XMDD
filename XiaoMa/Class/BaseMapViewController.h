//
//  BaseMapViewController.h
//  XiaoMa
//
//  Created by jt on 15-4-16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface BaseMapViewController : HKViewController<MAMapViewDelegate,AMapSearchDelegate>

@property (strong, nonatomic) MAMapView *mapView;

@property (nonatomic, strong) AMapSearchAPI *search;



@end
