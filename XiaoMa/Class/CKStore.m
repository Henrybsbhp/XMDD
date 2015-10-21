//
//  CKBaseModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CKStore.h"
static char sSubscribeBlockKey;
static char sStoreKey;
static char sTargetHashTableKey;

#define kDefTimetagKey @"$DefTimetag"

@interface CKStore ()
@property (nonatomic, strong) NSHashTable *weakTable;
@property (nonatomic, strong) NSMutableDictionary *timetagDict;
@end

@implementation CKStore

+ (NSMapTable *)storeTable
{
    static NSMapTable *g_storeTable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_storeTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    return g_storeTable;
}

+ (instancetype)fetchExistsStore
{
    CKStore *store = [[self storeTable] objectForKey:self];
    return store;
}

+ (instancetype)fetchOrCreateStore
{
    CKStore *store = [[self storeTable] objectForKey:self];
    if (!store) {
        store = [[self alloc] init];
        [[self storeTable] setObject:store forKey:self];
    }
    return store;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _weakTable = [NSHashTable weakObjectsHashTable];
        _cache = [[JTQueue alloc] init];
        _timetagDict = [NSMutableDictionary dictionary];
        _updateDuration = 60*60;
    }
    return self;
}

- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(CKStore *store, CKStoreEvent *evt))block
{
    objc_setAssociatedObject(target, &sSubscribeBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(target, &sStoreKey, block, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.weakTable addObject:target];
}

- (NSHashTable *)hashTableForTarget:(NSObject *)target
{
    NSHashTable *table = objc_getAssociatedObject(target, &sTargetHashTableKey);
    if (!table) {
        table = [NSHashTable hashTableWithOptions:NSPointerFunctionsCopyIn];
        objc_setAssociatedObject(target, &sTargetHashTableKey, table, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return table;
}

+ (CKStoreEvent *)sendEvent:(CKStoreEvent *)evt
{
    CKStore *store = [[self storeTable] objectForKey:self];
    return [store sendEvent:evt];
}

- (CKStoreEvent *)sendEvent:(CKStoreEvent *)evt
{
    for (NSObject *target in [[self.weakTable objectEnumerator] allObjects]) {
        void(^block)(CKStore *, CKStoreEvent *) = [target associatedObjectForKey:&sSubscribeBlockKey];
        if (block) {
            block(self, evt);
        }
    }
    return evt;
}

- (BOOL)needUpdateTimetagForKey:(NSString *)key
{
    if (!key) {
        key = kDefTimetagKey;
    }
    NSTimeInterval timetag = [[self.timetagDict objectForKey:key] doubleValue];
    return [[NSDate date] timeIntervalSince1970] - timetag > self.updateDuration;
}

- (void)updateTimetagForKey:(NSString *)key
{
    if (!key) {
        key = kDefTimetagKey;
    }
    [self.timetagDict setObject:@([[NSDate date] timeIntervalSince1970]) forKey:key];
}

@end

@implementation CKStoreEvent

- (instancetype)initWithSignal:(RACSignal *)sig code:(NSInteger)code object:(id)obj
{
    self = [super init];
    if (self) {
        _signal = sig;
        _code = code;
        _object = obj;
    }
    return self;
}

+ (instancetype)eventWithSignal:(RACSignal *)sig code:(NSInteger)code object:(id)obj
{
    return [[CKStoreEvent alloc] initWithSignal:sig code:code object:obj];
}

- (CKStoreEvent *)setSignal:(RACSignal *)signal
{
    return [CKStoreEvent eventWithSignal:signal code:self.code object:self.object];
}

- (BOOL)callIfNeededForCode:(NSInteger)code object:(id)obj target:(id)target selector:(SEL)selector
{
    CKStoreEvent *evt = self;
    if (target && selector && evt.code == code && (!obj || (obj && [obj isEqual:evt.object]))) {
        [self _callSelector:selector forTarget:target];
        return YES;
    }
    return NO;
}

- (BOOL)callIfNeededForCode:(NSInteger)code exceptObject:(id)obj target:(id)target selector:(SEL)selector
{
    if (self.object && [self.object isEqual:obj]) {
        return NO;
    }
    if (!self.object && !obj) {
        return NO;
    }
    [self _callSelector:selector forTarget:target];
    return YES;
}

- (BOOL)callIfNeededForCode:(NSInteger)code object:(id)obj handler:(void(^)(CKStoreEvent *))handler
{
    CKStoreEvent *evt = self;
    if (handler && evt.code == code && (!obj || (obj && [obj isEqual:evt.object]))) {
        handler(evt);
        return YES;
    }
    return NO;
}

- (void)_callSelector:(SEL)selector forTarget:(id)target
{
    //用于去掉xcode下面的警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [target performSelector:selector withObject:self];
#pragma clang diagnostic pop
}

@end


