//
//  PhoneHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PhoneHelper.h"
#import "JTShop.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DistanceCalcHelper.h"
#import "WXApi.h"

@implementation PhoneHelper

+ (PhoneHelper *)sharedHelper
{
    static dispatch_once_t onceToken;
    static PhoneHelper *g_phoneHelper;
    dispatch_once(&onceToken, ^{
        g_phoneHelper = [[PhoneHelper alloc] init];
    });
    return g_phoneHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.exsitBaiduMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:BaiduMapUrl]];
        self.exsitAMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:AMapUrl]];
        self.exsitWechat = [WXApi isWXAppInstalled];
//         使用canOpenURL可能会被拒绝，先用默认安装表示
//        self.exsitBaiduMap = YES;
//        self.exsitAMap = YES;
//        self.exsitWechat = YES;
    }
    return self;
}

- (void)navigationRedirectThirdMap:(JTShop *)shop andUserLocation:(CLLocationCoordinate2D)userCoordinate andView:(UIView *)view;
{
    UIActionSheet * sheet = [[UIActionSheet alloc] init];
    sheet.title = @"请选择导航软件";
    NSInteger cancelIndex = 1;
    // 添加苹果自带导航
    [sheet addButtonWithTitle:AppleNavigationStr];
    // 添加百度导航
    if (self.exsitBaiduMap) {
        [sheet addButtonWithTitle:BaiduNavigationStr];
        cancelIndex++;
    }
    // 添加高德导航
    if (self.exsitAMap) {
        [sheet addButtonWithTitle:AMapNavigationStr];
        cancelIndex++;
    }
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = cancelIndex;

    [sheet showInView:view];
    
    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * index) {
        NSString * title = [sheet buttonTitleAtIndex:[index integerValue]];
        
        // 如果点击了苹果导航
        if ([title equalByCaseInsensitive: AppleNavigationStr])
        {
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude) addressDictionary:nil]];
            toLocation.name = shop.shopName;
            
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving}];
        } // 如果点击了百度导航
        else if ([title equalByCaseInsensitive: BaiduNavigationStr])
        {
            CLLocationCoordinate2D  coordinate = CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude);
            CLLocationCoordinate2D  baiduCoordinate = [DistanceCalcHelper GCJ2BAIDU:coordinate];
            NSString * baiduUrlString = [[NSString stringWithFormat:@"baidumap://map/direction?mode=driving&origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&zoom=10&src=小马达达",userCoordinate.latitude,userCoordinate.longitude,baiduCoordinate.latitude,baiduCoordinate.longitude,shop.shopName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:baiduUrlString]];
        }// 如果点击了高德导航
        else if ([title equalByCaseInsensitive: AMapNavigationStr])
        {
            NSString *amapUrlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=0&style=2&poiname=%@&backScheme=amap.huika.xmdd",@"小马达达", @"com.huika.xmdd",shop.shopLatitude, shop.shopLongitude,shop.shopName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:amapUrlString]];
        }
    }];
}

- (void)makePhone:(NSString *)phoneNumber
{
    NSString * urlStr = [NSString stringWithFormat:@"tel://%@",phoneNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

- (void)makePhone:(NSString *)phoneNumber andInfo:(NSString *)info
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:nil message:info delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber *indexNum) {
        
        NSInteger index = [indexNum integerValue];
        if (index == 1)
        {
            NSString * urlStr = [NSString stringWithFormat:@"tel://%@",phoneNumber];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        }
    }];
    [av show];
}

@end
