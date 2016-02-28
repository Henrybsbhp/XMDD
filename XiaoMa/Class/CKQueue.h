//
//  CKQueue.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CKQueueNode;

@interface CKQueue : NSObject
@property (nonatomic, strong, readonly) NSNumber *queueid;
@property (nonatomic, strong) NSMutableDictionary *cache;

+ (instancetype)queue;
+ (instancetype)queueWithCache:(NSMutableDictionary *)cache;

- (void)addObject:(id)object forKey:(id<NSCopying>)key;
- (void)addObjectsFromQueue:(CKQueue *)queue;
- (void)addObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

- (void)removeObjectForKey:(id<NSCopying>)key;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)replaceObject:(id)object forKey:(id<NSCopying>)key;
- (void)insertObject:(id)object forKey:(id<NSCopying>)key atIndex:(NSInteger)index;

- (id)keyForObjectAtIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(id<NSCopying>)key;

- (NSUInteger)indexOfObjectForKey:(id<NSCopying>)key;
- (NSUInteger)count;
- (NSArray *)allObjects;

//Override
- (void)setObject:(id)object forKeyedSubscript:(id < NSCopying >)aKey;
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)anObject atIndexedSubscript:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (CKQueueNode *)createQueueNode;

@end

@interface CKQueueNode : NSObject

@property (nonatomic, strong) id object;
@property (nonatomic, strong) NSNumber *queueid;
@property (nonatomic, strong) id key;

@end

