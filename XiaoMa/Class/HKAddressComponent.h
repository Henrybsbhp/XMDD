//
//  HKAddressComponent.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapSearchKit/AMapSearchAPI.h>

@interface HKAddressComponent : NSObject<NSCoding, NSCopying>
+ (instancetype)addressComponentWith:(AMapAddressComponent *)component;
+ (BOOL)isEqualAddrComponent:(HKAddressComponent *)ac1 otherAddrComponent:(HKAddressComponent *)ac2;
+ (BOOL)isEqualAddrComponent:(HKAddressComponent *)ac1 AMapAddrComponent:(AMapAddressComponent *)ac2;

@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *district;
@property (nonatomic, strong) AMapStreetNumber *streetNumber;
@end
