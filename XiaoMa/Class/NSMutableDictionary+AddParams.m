//
//  NSMutableDictionary+AddParams.m
//  XiaoNiuShared
//
//  Created by jiangjunchen on 14-6-23.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "NSMutableDictionary+AddParams.h"
#import <objc/runtime.h>
static char s_firstparamKey;

@implementation NSMutableDictionary (AddParams)

- (void)addParam:(id)param forName:(NSString *)name
{
    if (!param)
    {
//        param = [NSNull null];
        return;
    }

    [self setObject:param forKey:name];
    if (!self.firstParam)
    {
        self.firstParam = param;
    }
}

- (id)firstParam
{
    return objc_getAssociatedObject(self, &s_firstparamKey);
}

- (void)setFirstParam:(id)param
{
    objc_setAssociatedObject(self, &s_firstparamKey, param, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSDictionary (GetParams)

- (id<NSObjectAutoConvertValueDelegate>)paramForName:(NSString *)name
{
    id obj = [self objectForKey:name];
    if ([obj isKindOfClass:[NSNull class]])
    {
        obj = nil;
    }
    return obj;
}


- (BOOL)boolParamForName:(NSString *)name
{
    return [[self paramForName:name] boolValue];
}

- (NSNumber *)numberParamForName:(NSString *)name
{
    return (NSNumber *)[self paramForName:name];
}

- (NSString *)stringParamForName:(NSString *)name
{
    return (NSString *)[self paramForName:name];
}
- (float)floatParamForName:(NSString *)name
{
    return [[self paramForName:name] floatValue];
}
- (NSInteger)integerParamForName:(NSString *)name
{
    return [[self paramForName:name] integerValue];
}
- (double)doubleParamForName:(NSString *)name
{
    return [[self paramForName:name] doubleValue];
}
- (int)intParamForName:(NSString *)name
{
    return [[self paramForName:name] intValue];
}

@end
