//
//  CKQueue.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKQueue.h"

@interface CKQueue () {
    NSMutableDictionary *__dict;
    NSMutableArray *__array;
}
@end

@implementation CKQueue

- (instancetype)init {
    
    self = [super init];
    if (self) {
        __array = [NSMutableArray array];
        __dict = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)queue {
    
    return [[self alloc] init];
}

+ (instancetype)queueWithObjectsAndKeys:(id)firstObject, ... {
    
    CKQueue *queue = [[self alloc] init];
    va_list argumentList;
    va_start(argumentList, firstObject);
    
    id object = firstObject;
    while (object) {
        [queue addObject:object forKey:va_arg(argumentList, id)];
        object = va_arg(argumentList, id);
    }
    va_end(argumentList);
    
    return queue;
}

- (void)setDictionary:(NSDictionary *)dict {
    
    [__dict setDictionary:dict];
}

- (NSDictionary *)dictionary {
    return __dict;
}

- (void)addObject:(id)object forKey:(id<NSCopying>)key {
    
    if (!object) {
        return;
    }

    if (key && ![[NSNull null] isEqual:key]) {
        NSArray *tuple = @[object, key];
        [__array addObject:tuple];
        [__dict setObject:tuple forKey:key];
    }
    else {
        [__array addObject:@[object]];
    }
}

- (void)addObjectsFromQueue:(CKQueue *)queue {
    
    [__dict setDictionary:queue->__dict];
    [__array addObjectsFromArray:queue->__array];
}

- (void)addObjectsAndKeys:(id)firstObject, ... {
    
    va_list argumentList;
    va_start(argumentList, firstObject);
    id object = firstObject;
    while (object) {
        [self addObject:object forKey:va_arg(argumentList, id)];
        object = va_arg(argumentList, id);
    }
    va_end(argumentList);
}

- (void)removeObjectForKey:(id<NSCopying>)key {
    
    NSArray *tuple = __dict[key];
    if (tuple) {
        [__array removeObject:tuple];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    
    //index超出范围
    if (index >= __array.count) {
        return;
    }
    NSArray *tuple = __array[index];
    [__array removeObjectAtIndex:index];
    if (tuple.count > 1) {
        [__dict removeObjectForKey:tuple[1]];
    }
}

- (void)insertObject:(id)object forKey:(id<NSCopying>)key atIndex:(NSInteger)index {
    
    //index超出范围
    if (index >= __array.count) {
        return;
    }
    if (key) {
        NSArray *tuple = @[object, key];
        [__array insertObject:tuple atIndex:index];
        [__dict setObject:tuple forKey:key];
    }
    else {
        [__array insertObject:@[object] atIndex:index];
    }
}

- (id)keyForObjectAtIndex:(NSUInteger)index {

    //index超出范围
    if (index >= __array.count) {
        return nil;
    }
    NSArray *tuple = __array[index];
    if (tuple.count > 1) {
        return tuple[1];
    }
    return nil;
}

- (id)objectAtIndex:(NSUInteger)index {
    
    //index超出范围
    if (index >= __array.count) {
        return nil;
    }
    NSArray *tuple = __array[index];
    return tuple[0];
}

- (id)objectForKey:(id<NSCopying>)key {
    
    NSArray *tuple = [__dict objectForKey:key];
    return tuple[0];
}

- (NSUInteger)indexOfObjectForKey:(id<NSCopying>)key {
    
    NSArray *tuple = __dict[key];
    if (tuple) {
        return [__array indexOfObject:tuple];
    }
    return NSNotFound;
}

- (NSUInteger)count {
    
    return __array.count;
}

- (NSArray *)allObjects {

    NSMutableArray *objs = [NSMutableArray arrayWithCapacity:__array.count];
    for (NSArray *tuple in __array) {
        [objs addObject:tuple[0]];
    }
    return objs;
}

@end
