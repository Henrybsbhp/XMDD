//
//  HKAddressComponent.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKAddressComponent.h"

@implementation HKAddressComponent

+ (instancetype)addressComponentWith:(AMapAddressComponent *)otherComponent
{
    HKAddressComponent *component = [[HKAddressComponent alloc] init];
    component.province = otherComponent.province;
    component.city = otherComponent.city;
    component.district = otherComponent.district;
    component.streetNumber = otherComponent.streetNumber;
    return component;
}

+ (BOOL)isEqualAddrComponent:(HKAddressComponent *)ac1 otherAddrComponent:(HKAddressComponent *)ac2
{
    if ((!ac1.province && ac2.province) && ![ac1.province isEqualToString:ac2.province]) {
        return NO;
    }
    if ((!ac1.city && ac2.city) && ![ac1.city isEqualToString:ac2.city]) {
        return NO;
    }
    if ((!ac1.district && ac2.district) && ![ac1.district isEqualToString:ac2.district]) {
        return NO;
    }
    return YES;
}

+ (BOOL)isEqualAddrComponent:(HKAddressComponent *)ac1 AMapAddrComponent:(AMapAddressComponent *)ac2
{
    if ((!ac1.province && ac2.province) && ![ac1.province isEqualToString:ac2.province]) {
        return NO;
    }
    if ((!ac1.city && ac2.city) && ![ac1.city isEqualToString:ac2.city]) {
        return NO;
    }
    if ((!ac1.district && ac2.district) && ![ac1.district isEqualToString:ac2.district]) {
        return NO;
    }
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.province forKey:@"province"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.district forKey:@"district"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.province = [coder decodeObjectForKey:@"province"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.district = [coder decodeObjectForKey:@"district"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    HKAddressComponent *copy = [[[self class] alloc] init];
    if (copy) {
        copy.province = _province;
        copy.city = _city;
        copy.district = _district;
    }
    
    return copy;
}

@end
