//
//  CKBaseModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CKStore.h"
static char sTargetHashTableKey;

#define kDefTimetagKey @"$DefTimetag"

@interface CKStore ()
@property (nonatomic, strong) NSMapTable *weakTable;
@property (nonatomic, strong) NSMutableDictionary *timetagDict;
@property (nonatomic, strong) id<NSFastEnumeration> innerStores;
@end

@implementation CKStore

- (void)dealloc
{
    
}

+ (NSMapTable *)storeTable
{
    static NSMapTable *g_storeTable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_storeTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    return g_storeTable;
}

+ (instancetype)fetchExistsStore
{
    return [self fetchExistsStoreForWeakKey:self];
}

+ (instancetype)fetchOrCreateStore
{
    return [self fetchOrCreateStoreForWeakKey:self];
}

+ (instancetype)fetchExistsStoreForWeakKey:(id)key
{
    CKStore *store = [[self storeTable] objectForKey:key];
    return store;
}

+ (instancetype)fetchOrCreateStoreForWeakKey:(id)key
{
    CKStore *store = [self fetchExistsStoreForWeakKey:key];
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
        _weakTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsCopyIn];
        _cache = [[JTQueue alloc] init];
        _timetagDict = [NSMutableDictionary dictionary];
        _updateDuration = 60*60;
    }
    return self;
}

+ (instancetype)merge:(id<NSFastEnumeration>)stores
{
    CKStore *mergedStore = [[self alloc] init];
    mergedStore.innerStores = stores;
    @weakify(mergedStore);
    for (CKStore *store in stores) {
        [store subscribeEventsWithTarget:mergedStore receiver:^(CKStore *store, CKStoreEvent *evt) {
            @strongify(mergedStore);
            for (void(^block)(CKStore *, CKStoreEvent *) in [[mergedStore.weakTable objectEnumerator] allObjects]) {
                block(store, evt);
            }
        }];
    }
    return mergedStore;
}

- (instancetype)merge:(id<NSFastEnumeration>)store
{
    return [CKStore merge:@[self, store]];
}


- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(CKStore *store, CKStoreEvent *evt))block
{
    [self.weakTable setObject:block forKey:target];
}

- (void)removeSubscriptionForTarget:(id)target
{
    [self.weakTable removeObjectForKey:target];
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
    for (void(^block)(CKStore *, CKStoreEvent *) in [[self.weakTable objectEnumerator] allObjects]) {
        block(self, evt);
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

- (BOOL)callIfNeededExceptCodeList:(NSArray *)codes object:(id)obj target:(id)target selector:(SEL)selector
{
    if (target && selector && (!obj || (obj && [obj isEqual:self.object])) && ![codes containsObject:@(self.code)]) {
        [self _callSelector:selector forTarget:target];
        return YES;
    }
    return NO;

}

- (BOOL)callIfNeededExceptCode:(NSInteger)code object:(id)obj target:(id)target selector:(SEL)selector
{
    if (target && selector && self.code != code && (!obj || (obj && [obj isEqual:self.object]))) {
        [self _callSelector:selector forTarget:target];
        return YES;
    }
    return NO;
}

- (BOOL)callIfNeededForCodeList:(NSArray *)codes object:(id)obj target:(id)target selector:(SEL)selector
{
    CKStoreEvent *evt = self;
    if (target && selector && (!obj || (obj && [obj isEqual:evt.object])) && [codes containsObject:@(evt.code)]) {
        [self _callSelector:selector forTarget:target];
        return YES;
    }
    return NO;

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

- (BOOL)callIfNeededExceptCodeList:(NSArray *)codes object:(id)obj handler:(void(^)(CKStoreEvent *))handler
{
    CKStoreEvent *evt = self;
    if (handler && (!obj || (obj && [obj isEqual:evt.object])) && ![codes containsObject:@(evt.code)]) {
        [self performSelector:@selector(_callhandler:withEvent:) withObject:handler withObject:evt];
        return YES;
    }
    return NO;
}

- (BOOL)callIfNeededExceptCode:(NSInteger)code object:(id)obj handler:(void(^)(CKStoreEvent *))handler
{
    CKStoreEvent *evt = self;
    if (handler && evt.code != code && (!obj || (obj && [obj isEqual:evt.object]))) {
        [self performSelector:@selector(_callhandler:withEvent:) withObject:handler withObject:evt];
        return YES;
    }
    return NO;
}

- (BOOL)callIfNeededForCodeList:(NSArray *)codes object:(id)obj handler:(void(^)(CKStoreEvent *))handler
{
    CKStoreEvent *evt = self;
    if (handler && (!obj || (obj && [obj isEqual:evt.object])) && [codes containsObject:@(evt.code)]) {
        [self performSelector:@selector(_callhandler:withEvent:) withObject:handler withObject:evt];
        return YES;
    }
    return NO;
}

- (BOOL)callIfNeededForCode:(NSInteger)code object:(id)obj handler:(void(^)(CKStoreEvent *))handler
{
    CKStoreEvent *evt = self;
    if (handler && evt.code == code && (!obj || (obj && [obj isEqual:evt.object]))) {
        [self performSelector:@selector(_callhandler:withEvent:) withObject:handler withObject:evt];
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

- (void)_callhandler:(void(^)(CKStoreEvent *))handler withEvent:(CKStoreEvent *)evt
{
    handler(evt);
}


@end


