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

@interface PhoneHelper ()

@property (nonatomic)NSInteger cancelIndex;

@end


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
//        self.exsitBaiduMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:BaiduMapUrl]];
//        self.exsitAMap = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:AMapUrl]];
//        self.exsitWechat = [WXApi isWXAppInstalled];
        // 使用canOpenURL可能会被拒绝，先用默认安装表示
        self.exsitBaiduMap = YES;
        self.exsitAMap = YES;
        self.exsitWechat = YES;
    }
    return self;
}

- (void)navigationRedirectThireMap:(JTShop *)shop andUserLocation:(CLLocationCoordinate2D)userCoordinate andView:(UIView *)view;
{
    self.cancelIndex = 1;
    
    UIActionSheet * sheet;
    if (self.exsitBaiduMap)
    {
        if (self.exsitAMap)
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,BaiduNavigationStr,AMapNavigationStr,nil];
            self.cancelIndex = 3;
        }
        else
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,BaiduNavigationStr,nil];
            self.cancelIndex = 2;
        }
    }
    else
    {
        if (self.exsitAMap)
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,AMapNavigationStr,nil];
            self.cancelIndex = 2;
        }
        else
        {
            sheet = [[UIActionSheet alloc] initWithTitle:@"请选择导航软件" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:AppleNavigationStr,nil];
            self.cancelIndex = 1;
        }
    }
    
    [sheet showInView:view];
    
    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * index) {
        
        NSInteger buttonIndex = [index integerValue];
        
        if (buttonIndex == self.cancelIndex)
        {
            return;
        }
        
        NSString * baiduUrlString = [[NSString stringWithFormat:@"baidumap://map/direction?mode=driving&origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:%@&zoom=10&src=小马达达",userCoordinate.latitude,userCoordinate.longitude,shop.shopLatitude,shop.shopLongitude,shop.shopName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *amapUrlString = [[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%f&lon=%f&dev=1&style=2&poiname=%@&backScheme=amap.huika.xmdd",@"小马达达", @"com.huika.xmdd",shop.shopLatitude, shop.shopLongitude,shop.shopName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (buttonIndex == 0)
        {
            
            MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
            MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:CLLocationCoordinate2DMake(shop.shopLatitude, shop.shopLongitude) addressDictionary:nil]];
            toLocation.name = shop.shopName;
            
            [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                           launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
        }
        else if (buttonIndex == 1)
        {
            if (self.exsitBaiduMap)
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:baiduUrlString]];
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:amapUrlString]];
                
            }
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:amapUrlString]];
        }
    }];
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
