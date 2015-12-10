//
//  CKStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CKStore.h"

@interface CKStore ()
@property (nonatomic, strong) NSMapTable *weakTable;
@end

@implementation CKStore

+ (NSMapTable *)storeTable
{
    static NSMapTable *g_storeTable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_storeTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    });
    return g_storeTable;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        _weakTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsStrongMemory];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Fetch
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

+ (instancetype)fetchExistsStore
{
    return [self fetchExistsStoreForWeakKey:self];
}

+ (instancetype)fetchOrCreateStore
{
    return [self fetchOrCreateStoreForWeakKey:self];
}

#pragma mark - Observe
- (void)observeEventForName:(NSString *)name selector:(SEL)selector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:selector
                                                 name:[CKEvent wholeEventName:name] object:nil];
}

- (void)observeEventForName:(NSString *)name handler:(void(^)(CKEvent *))handler
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_onReceiveEvent:handler:)
                                                 name:[CKEvent wholeEventName:name] object:handler];
}

- (CKEvent *)observeEvent:(CKEvent *)event selector:(SEL)selector
{
    [self observeEventForName:event.name selector:selector];
    return event;
}

- (CKEvent *)observeEvent:(CKEvent *)event handler:(void(^)(CKEvent *))handler
{
    [self observeEventForName:event.name handler:handler];
    return event;
}

- (void)_onReceiveEvent:(CKEvent *)event handler:(void(^)(CKEvent *))handler
{
    handler(event);
}

#pragma mark - Trigger
- (void)triggerForDomain:(NSString *)domain event:(CKEvent *)event
{
    for (NSDictionary *dict in [[self.weakTable objectEnumerator] allObjects]) {
       void(^block)(CKStore *, CKEvent *) = [dict objectForKey:domain];
        if (block) {
            block(self, event);
        }
    }
}

#pragma mark - Subscribe
- (void)subscribeWithTarget:(id)target domain:(NSString *)domain receiver:(void(^)(CKStore *store, CKEvent*evt))block
{
    NSMutableDictionary *dict = [self.weakTable objectForKey:target];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
        [self.weakTable setObject:dict forKey:target];
        @weakify(self);
        @weakify(target);
        [[target rac_willDeallocSignal] subscribeCompleted:^{
            @strongify(self);
            @strongify(target);
            [self.weakTable removeObjectForKey:target];
        }];
    }
    [dict setObject:[block copy] forKey:domain];
}


@end
