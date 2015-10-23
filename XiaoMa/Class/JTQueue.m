//
//  JTQueue.m
//  EasyPay
//
//  Created by jiangjunchen on 14/12/4.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "JTQueue.h"

@interface JTQueue ()
@property (atomic, strong) NSMutableArray *mQueue;
@property (nonatomic, strong) NSMutableDictionary *mObjectMap;
@property (nonatomic, weak) RACTuple *runningTuple;

@end

@implementation JTQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mQueue = [NSMutableArray array];
        self.mObjectMap = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setRunning:(BOOL)running
{
    _running = running;
    if (_running) {
        [self consumeForce:NO];
    }
}

- (NSArray *)allObjects
{
    return [self.mQueue arrayByMapFilteringOperator:^id(RACTuple *obj) {

        return obj.first;
    }];
}

- (NSInteger)indexOfObjectForKey:(id<NSCopying>)key
{
    RACTuple *tuple = [self.mObjectMap objectForKey:key];
    return [self.mQueue indexOfObject:tuple];
}

- (id)objectAtIndex:(NSInteger)index
{
    RACTuple *tuple = [self.mQueue safetyObjectAtIndex:index];
    return tuple ? tuple.first : nil;
}

- (id)objectForKey:(id<NSCopying>)key
{
    RACTuple *tuple = [self.mObjectMap objectForKey:key];
    return tuple ? tuple.first : nil;
}

- (void)addObject:(id)object forKey:(id<NSCopying>)key
{
    if (!object) {
        return;
    }
    RACTuple *tuple = RACTuplePack(object, key);
    if (self.mQueue.count == 0 && self.running) { //Q&A: 这里为什么要增加running的判断？
        [self.mQueue safetyAddObject:tuple];
        [self.mObjectMap safetySetObject:tuple forKey:key];
        [self consumeForce:NO];
    }
    else if (key) {
        id old = [self.mObjectMap objectForKey:key];
        if (old && ![self.runningTuple isEqual:old]) {
            NSInteger index = [self.mQueue indexOfObject:old];
            [self.mQueue safetyReplaceObjectAtIndex:index withObject:tuple];
        }
        else {
            [self.mQueue safetyAddObject:tuple];
        }
        
        [self.mObjectMap safetySetObject:tuple forKey:key];
    }
    else {
        [self.mQueue safetyAddObject:tuple];
    }
    self.count = self.mQueue.count;
}

- (void)removeObjectForKey:(id<NSCopying>)key
{
    id obj = [self.mObjectMap objectForKey:key];
    if (obj) {
        [self.mQueue safetyRemoveObject:obj];
        [self.mObjectMap removeObjectForKey:key];
    }
    self.count = self.mQueue.count;
}

- (void)removeAllObjects
{
    [self.mObjectMap removeAllObjects];
    [self.mQueue removeAllObjects];
    self.count = 0;
}

- (void)consumeForce:(BOOL)force
{
    RACTuple *tuple = [self.mQueue safetyObjectAtIndex:0];
    BOOL run = self.running || force;
    if (tuple && run && self.consumeBlock) {
        RACSignal *sig = self.consumeBlock(tuple.first, tuple.second);
        self.runningTuple = tuple;
        [[sig catch:^RACSignal *(NSError *error) {
            
            return [RACSignal empty];
        }] subscribeCompleted:^{
            [self.mQueue safetyRemoveObject:tuple];
            self.count = self.mQueue.count;
            NSString *key = tuple.second;
            if (key) {
                RACTuple *tempTuple = [self.mObjectMap objectForKey:key];
                if (tempTuple && [tempTuple isEqual:tuple]) {
                    [self.mObjectMap removeObjectForKey:key];
                }
            }
            self.runningTuple = nil;
            [self consumeForce:NO];
        }];
    }
}
@end
