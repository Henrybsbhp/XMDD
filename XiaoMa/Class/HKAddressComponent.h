//
//  HKAddressComponent.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKAddressComponent : NSObject<NSCoding, NSCopying>
+ (instancetype)addressComponentWith:(AMapAddressComponent *)component;
- (BOOL)isEqualToAMapAddressComponent:(AMapAddressComponent *)component;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *district;

@end
