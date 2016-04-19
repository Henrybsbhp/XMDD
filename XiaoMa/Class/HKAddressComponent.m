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
    component.street = otherComponent.streetNumber.street;
    component.number = otherComponent.streetNumber.number;
    return component;
}

+ (BOOL)isEqualAddrComponent:(HKAddressComponent *)ac1 otherAddrComponent:(HKAddressComponent *)ac2
{
    if (![ac1.province isEqualToString:ac2.province]) {
        return NO;
    }
    if (![ac1.city isEqualToString:ac2.city]) {
        return NO;
    }
    if (![ac1.district isEqualToString:ac2.district]) {
        return NO;
    }
    if (![ac1.district isEqualToString:ac2.street]) {
        return NO;
    }
    if (![ac1.district isEqualToString:ac2.number]) {
        return NO;
    }
    return YES;
}

+ (BOOL)isEqualAddrComponent:(HKAddressComponent *)ac1 AMapAddrComponent:(AMapAddressComponent *)ac2
{
    if (![ac1.province isEqualToString:ac2.province]) {
        return NO;
    }
    if (![ac1.city isEqualToString:ac2.city]) {
        return NO;
    }
    if (![ac1.district isEqualToString:ac2.district]) {
        return NO;
    }
    if (![ac1.district isEqualToString:ac2.streetNumber.street]) {
        return NO;
    }
    if (![ac1.district isEqualToString:ac2.streetNumber.number]) {
        return NO;
    }
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.province forKey:@"province"];
    [coder encodeObject:self.city forKey:@"city"];
    [coder encodeObject:self.district forKey:@"district"];
    [coder encodeObject:self.street forKey:@"street"];
    [coder encodeObject:self.number forKey:@"number"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.province = [coder decodeObjectForKey:@"province"];
        self.city = [coder decodeObjectForKey:@"city"];
        self.district = [coder decodeObjectForKey:@"district"];
        self.street = [coder decodeObjectForKey:@"street"];
        self.number = [coder decodeObjectForKey:@"number"];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    HKAddressComponent *copy = [[[self class] alloc] init];
    if (copy) {
        copy.province = _province;
        copy.city = _city;
        copy.district = _district;
        copy.street = _street;
        copy.number = _number;
    }
    
    return copy;
}

@end
