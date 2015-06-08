//
//  NSObject+AutoConvertValue.m
//  XiaoNiuShared
//
//  Created by jiangjunchen on 14-7-20.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "NSObject+AutoConvertValue.h"

@implementation NSObject (AutoConvertValue)

- (float)floatValue
{
    if ([self isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)self floatValue];
    }
    return 0;
}
- (NSInteger)integerValue
{
    if ([self isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)self integerValue];
    }
    return 0;
}
- (double)doubleValue
{
    if ([self isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)self doubleValue];
    }
    return 0;
}
- (int)intValue
{
    if ([self isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)self intValue];
    }
    return 0;
}

- (BOOL)boolValue
{
    if ([self isKindOfClass:[NSNumber class]])
    {
        return [(NSNumber *)self boolValue];
    }
    return NO;
}

@end
