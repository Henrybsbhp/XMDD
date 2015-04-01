//
//  NSString+Safety.m
//  JTNewReader
//
//  Created by jiangjunchen on 14-3-18.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "NSString+Safety.h"

@implementation NSString (Safety)

+ (NSString *)safetyStringWithString:(NSString *)aString
{
    if (aString)
    {
        return [self stringWithString:aString];
    }
    return nil;
}

+ (NSString *)stringNotNullFrom:(NSString *)aString
{
    if (aString)
    {
        return aString;
    }
    return @"";
}

@end

@implementation NSMutableString (Safety)

- (void)safetyAppendString:(NSString *)aString
{
    if (aString)
    {
        [self appendString:aString];
    }
}


@end
