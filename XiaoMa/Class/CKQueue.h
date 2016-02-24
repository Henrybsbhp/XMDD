//
//  CKQueue.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CKQueue : NSObject

+ (instancetype)queue;
+ (instancetype)queueWithObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

- (void)setDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionary;

- (void)addObject:(id)object forKey:(id<NSCopying>)key;
- (void)addObjectsFromQueue:(CKQueue *)queue;
- (void)addObjectsAndKeys:(id)firstObject, ... NS_REQUIRES_NIL_TERMINATION;

- (void)removeObjectForKey:(id<NSCopying>)key;
- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)insertObject:(id)object forKey:(id<NSCopying>)key atIndex:(NSInteger)index;

- (id)keyForObjectAtIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;
- (id)objectForKey:(id<NSCopying>)key;

- (NSUInteger)indexOfObjectForKey:(id<NSCopying>)key;
- (NSUInteger)count;
- (NSArray *)allObjects;

@end
