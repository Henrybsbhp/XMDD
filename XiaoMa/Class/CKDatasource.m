//
//  CKDatasource.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/1/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKDatasource.h"

#pragma mark - CKList

@interface CKList ()
{
    id _key;
}
@end

@implementation CKList

+ (instancetype)list {
    return [self queue];
}

+ (instancetype)listWithArray:(NSArray *)array
{
    CKList *list = [self queue];
    for (id obj in array) {
        [list addObject:obj forKey:nil];
    }
    return list;
}

- (id<NSCopying>)key {
    if (_key) {
        return _key;
    }
    return self.queueid;
}

- (instancetype)setKey:(id<NSCopying>)key {
    _key = key;
    return self;
}

- (void)addObject:(id)object forKey:(id<NSCopying>)key {
    if (!key && [self respondsToSelector:@selector(key)]) {
        [super addObject:object forKey:[object key]];
    }
    else {
        [super addObject:object forKey:key];
    }
}

@end

#pragma mark - CKDict

@interface CKDict ()
{
    NSMutableDictionary *_dict;
}

@end

@implementation CKDict

- (instancetype)init {
    self = [super init];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (CKDict *)dictWithCKDict:(CKDict *)dict {
    return [[CKDict alloc] initWithDict:dict->_dict];
}

+ (CKDict *)dictWith:(NSDictionary *)dict {
    return [[CKDict alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        _dict = [NSMutableDictionary dictionaryWithDictionary:dict];
    }
    return self;
}


- (id<NSCopying>)key {
    return _dict[kCKItemKey];
}

- (instancetype)setKey:(id<NSCopying>)key {
    _dict[kCKItemKey] = key;
    return self;
}

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey {
    [_dict setObject:object forKey:aKey];
}

- (id)objectForKeyedSubscript:(id)key {
    return [_dict objectForKey:key];
}

@end

#pragma mark - C语言扩展
CKCellSelectedBlock CKCellSelected(CKCellSelectedBlock block)
{
    return [block copy];
}

CKCellGetHeightBlock CKCellGetHeight(CKCellGetHeightBlock block)
{
    return [block copy];
}

CKCellPrepareBlock CKCellPrepare(CKCellPrepareBlock block)
{
    return [block copy];
}

CKList *CKGenList(id firstObject, ...)
{
    CKList *list = [CKList queue];
    
    va_list ap;
    va_start(ap, firstObject);
    id obj = firstObject;
    while (obj) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            obj = [[CKDict alloc] initWithDict:obj];
        }
        //如果为CKNULL直接忽略
        if (![CKNULL isEqual:obj]) {
            [list addObject:obj forKey:nil];            
        }
        obj = va_arg(ap, id);
    }
    va_end(ap);
    
    return list;
}
