//
//  CKBaseModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CKStore.h"
static char sSubscribeBlockKey;
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

+ (instancetype)fetchStore
{
    CKStore *store = [[self storeTable] objectForKey:self];
    if (!store) {
        store = [[self alloc] init];
        [[self storeTable] setObject:store forKey:self];
    }
    return store;
}

+ (void)reloadData
{
    CKStore *store = [[self storeTable] objectForKey:self];
    [store reloadData];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _weakTable = [NSHashTable weakObjectsHashTable];
    }
    return self;
}

- (void)subscribeEventsWithTarget:(id)target receiver:(void(^)(RACSignal *event, NSInteger code))block
{
    [(NSObject *)target setAssociatedObject:block forKey:&sSubscribeBlockKey policy:OBJC_ASSOCIATION_COPY_NONATOMIC];
    [self.weakTable addObject:target];
}

- (void)sendEvent:(RACSignal *)event withCode:(NSInteger)code
{
    for (NSObject *target in [[self.weakTable objectEnumerator] allObjects]) {
        void(^block)(RACSignal *, NSInteger) = [target associatedObjectForKey:&sSubscribeBlockKey];
        if (block) {
            block(event, code);
        }
    }
}

@end
