//
//  CKMap.m
//  JTReader
//
//  Created by jiangjunchen on 13-12-8.
//  Copyright (c) 2013年 jiangjunchen. All rights reserved.
//

#import "CKMap.h"

@interface CKMap ()
@property (nonatomic, strong) NSMutableDictionary *mDict;
@end
@implementation CKMap

- (void)addObjects:(NSArray *)objs forKey:(NSString *)key
{
    if (!_mDict)
    {
        _mDict = [NSMutableDictionary dictionary];
    }
    NSMutableArray *objArray = [_mDict objectForKey:key];
    if (!objArray)
    {
        objArray = [NSMutableArray array];
        [_mDict setObject:objArray forKey:key];
    }
    [objArray addObjectsFromArray:objs];
}

- (void)addObject:(id)obj forKey:(NSString *)key
{
    if (!_mDict)
    {
        _mDict = [NSMutableDictionary dictionary];
    }
    NSMutableArray *objArray = [_mDict objectForKey:key];
    if (!objArray)
    {
        objArray = [NSMutableArray array];
        [_mDict setObject:objArray forKey:key];
    }
    [objArray addObject:obj];
}

- (NSArray *)objectsForKey:(NSString *)key
{
    return [_mDict objectForKey:key];
}

- (NSArray *)allKeys
{
    return _mDict.allKeys;
}

- (NSArray *)allObjects
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *values = [_mDict allValues];
    for (NSMutableArray *objArray in values)
    {
        [array addObjectsFromArray:objArray];
    }
    return array;
}

- (void)removeAllObjects
{
    [_mDict removeAllObjects];
}
@end
