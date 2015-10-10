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

@interface CKStore ()
@property (nonatomic, strong) NSHashTable *weakTable;
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

+ (void)reloadDataWithCode:(NSInteger)code
{
    CKStore *store = [[self storeTable] objectForKey:self];
    [store reloadDataWithCode:code];
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
    }
    return self;
}

- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(CKStore *store, RACSignal *evt, NSInteger code))block
{
    objc_setAssociatedObject(target, &sSubscribeBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(target, &sStoreKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.weakTable addObject:target];
}

+ (void)sendEvent:(RACSignal *)event withCode:(NSInteger)code
{
    CKStore *store = [[self storeTable] objectForKey:self];
    [store sendEvent:event withCode:code];
}

- (void)sendEvent:(RACSignal *)event withCode:(NSInteger)code
{
    for (NSObject *target in [[self.weakTable objectEnumerator] allObjects]) {
        void(^block)(CKStore *, RACSignal *, NSInteger) = [target associatedObjectForKey:&sSubscribeBlockKey];
        if (block) {
            block(self, event, code);
        }
    }
}

//@Override
- (void)reloadDataWithCode:(NSInteger)code
{
    
}

@end
