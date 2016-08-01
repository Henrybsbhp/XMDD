//
//  JTQueue.h
//  EasyPay
//
//  Created by jiangjunchen on 14/12/4.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JTQueue : NSObject

///queue开始流动前要设置该block，用于消耗queue中的object，并返回本次消耗操作的具体信号，如果信号发生error，则跳过
@property (nonatomic, copy) RACSignal* (^consumeBlock)(id obj, id<NSCopying> key);
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) NSInteger count;


- (NSArray *)allObjects;
- (void)addObject:(id)object forKey:(id<NSCopying>)key;
- (void)insertObject:(id)object forKey:(id<NSCopying>)key atIndex:(NSInteger)index;
- (NSInteger)indexOfObjectForKey:(id<NSCopying>)key;
- (id)keyForObjectAtIndex:(NSInteger)index;
- (id)objectAtIndex:(NSInteger)index;
- (id)objectForKey:(id<NSCopying>)key;
- (void)removeObjectForKey:(id<NSCopying>)key;
- (void)removeObjectAtIndex:(NSInteger)index;
- (void)removeAllObjects;

@end
