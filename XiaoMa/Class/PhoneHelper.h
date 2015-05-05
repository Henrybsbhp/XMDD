//
//  PhoneHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>


@class JTShop;

@interface PhoneHelper : NSObject

@property (nonatomic)BOOL exsitBaiduMap;
@property (nonatomic)BOOL exsitAMap;
@property (nonatomic)BOOL exsitWechat;

+ (PhoneHelper *)sharedHelper;

- (void)navigationRedirectThireMap:(JTShop *)shop andUserLocation:(CLLocationCoordinate2D)userCoordinate andView:(UIView *)view;


- (void)makePhone:(NSString *)phoneNumber andInfo:(NSString *)info;
@end
