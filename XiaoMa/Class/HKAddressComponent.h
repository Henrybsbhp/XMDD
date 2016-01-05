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

@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *number;
@end
