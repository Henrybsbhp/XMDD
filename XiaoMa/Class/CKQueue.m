//
//  CKQueue.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKQueue.h"

@interface CKQueue ()
@property (nonatomic, strong) NSMutableArray *array;
@end

static unsigned long long g_queueid = 0;

@implementation CKQueue

- (instancetype)initWithCache:(NSMutableDictionary *)cache {
    
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
        _cache = cache;
        _queueid = @(g_queueid++);
    }
    return self;
}

+ (instancetype)queue {
    
    return [[self alloc] initWithCache:[NSMutableDictionary dictionary]];
}

+ (instancetype)queueWithCache:(NSMutableDictionary *)cache
{
    return [[self alloc] initWithCache:cache];
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [NSMutableArray array];
    }
    return _array;
}

- (void)addObject:(id)object forKey:(id<NSCopying>)key {
    
    if (!object) {
        return;
    }

    CKQueueNode *node = [self createQueueNode];
    node.object = object;
    node.queueid = _queueid;
    if (key && ![[NSNull null] isEqual:key]) {
        node.key = key;
        [self.cache setObject:node forKey:key];
    }
    [self.array addObject:node];
}

- (void)addObjectsFromQueue:(CKQueue *)queue {
    
    if (![self.cache isEqual:queue.cache]) {
        [self.cache setDictionary:queue.cache];
    }
    [self.array addObjectsFromArray:queue.array];
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
    
    CKQueueNode *node = self.cache[key];
    if (node) {
        [self.array removeObject:node];
    }
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    
    //index超出范围
    if (index >= self.array.count) {
        return;
    }
    CKQueueNode *node = self.array[index];
    [self.array removeObjectAtIndex:index];
    if (node.key) {
        [self.cache removeObjectForKey:node.key];
    }
}

- (void)replaceObject:(id)object forKey:(id<NSCopying>)key {
    CKQueueNode *oldNode = self.cache[key];
    if (oldNode) {
        NSInteger index = [self.array indexOfObject:oldNode];
        if (index != NSNotFound) {
            CKQueueNode *newNode = [self createQueueNode];
            newNode.object = object;
            newNode.queueid = _queueid;
            newNode.key = key;
            [self.array replaceObjectAtIndex:index withObject:newNode];
        }
    }
}

- (void)replaceObject:(id)object withKey:(id<NSCopying>)key atIndex:(NSInteger)index {
    //index超出范围
    if (index >= self.array.count) {
        return;
    }
    CKQueueNode *oldNode = self.array[index];
    if (oldNode) {
        CKQueueNode *newNode = [self createQueueNode];
        newNode.object = object;
        newNode.queueid = _queueid;
        if (key && ![[NSNull null] isEqual:key]) {
            newNode.key = key;
            [self.cache setObject:newNode forKey:key];
        }
        [self.array replaceObjectAtIndex:index withObject:newNode];
    }
}

- (void)insertObject:(id)object withKey:(id<NSCopying>)key atIndex:(NSInteger)index {
    
    //index超出范围
    if (index > self.array.count) {
        return;
    }
    CKQueueNode *node = [self createQueueNode];
    node.object = object;
    node.queueid = _queueid;
    node.key = key;
    if (key) {
        [self.cache setObject:node forKey:key];
    }
    if (index < self.array.count) {
        [self.array insertObject:node atIndex:index];
    }
    else {
        [self.array addObject:node];
    }
}

- (id)keyForObjectAtIndex:(NSUInteger)index {

    //index超出范围
    if (index >= self.array.count) {
        return nil;
    }
    CKQueueNode *node = self.array[index];
    return node.key;
}

- (id)objectAtIndex:(NSUInteger)index {
    
    //index超出范围
    if (index >= self.array.count) {
        return nil;
    }
    CKQueueNode *node = self.array[index];
    return node.object;
}

- (id)objectForKey:(id<NSCopying>)key {
    
    CKQueueNode *node = [self.cache objectForKey:key];
    return node.object;
}

- (NSUInteger)indexOfObjectForKey:(id<NSCopying>)key {
    
    CKQueueNode *node = self.cache[key];
    if (node) {
        return [self.array indexOfObject:node];
    }
    return NSNotFound;
}

- (NSUInteger)count {
    
    return self.array.count;
}

- (NSArray *)allObjects {

    NSMutableArray *objs = [NSMutableArray arrayWithCapacity:self.array.count];
    for (CKQueueNode *node in self.array) {
        [objs addObject:node.object];
    }
    return objs;
}

#pragma mark - Override

- (CKQueueNode *)createQueueNode {
    return [[CKQueueNode alloc] init];
}

- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey {
    [self addObject:object forKey:aKey];
}
- (id)objectForKeyedSubscript:(id)key {
    return [self objectForKey:key];
}
- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index {
    [self setObject:anObject atIndexedSubscript:index];
}
- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return [self objectAtIndex:index];
}


@end

@implementation CKQueueNode


@end
