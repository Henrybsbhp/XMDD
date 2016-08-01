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

- (void)navigationRedirectThirdMap:(JTShop *)shop andUserLocation:(CLLocationCoordinate2D)userCoordinate andView:(UIView *)view;


- (void)makePhone:(NSString *)phoneNumber andInfo:(NSString *)info;
- (void)makePhone:(NSString *)phoneNumber;

///检查拍照是否被授权
- (BOOL)isCameraAuthStatusAllowed;
///处理拍照是否被授权
- (BOOL)handleCameraAuthStatusDenied;
@end
