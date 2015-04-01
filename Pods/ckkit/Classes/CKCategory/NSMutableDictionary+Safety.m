//
//  NSMutableDictionary+Safety.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-26.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

@implementation NSMutableDictionary (Safety)

- (void)safetySetObject:(id)anObject forKey:(id)aKey
{
    if (anObject && aKey)
    {
        [self setObject:anObject forKey:aKey];
    }
}

@end
