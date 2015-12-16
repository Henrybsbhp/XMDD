//
//  CKStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CKStore.h"
#import "CKDispatcher.h"

@interface CKStore ()
@property (nonatomic, strong) NSMapTable *weakTable;
@property (nonatomic, strong) NSMutableDictionary *eventDict;
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
        _eventDict = [NSMutableDictionary dictionary];
    }
    return self;
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
    RACDisposable *dsp = [[[CKDispatcher sharedDispatcher] rac_addObserverForEventName:name] subscribeNext:^(CKEvent *event) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:selector withObject:event];
#pragma clang diagnostic pop
    }];
    [[self rac_deallocDisposable] addDisposable:dsp];
}

- (void)observeEventForName:(NSString *)name handler:(void(^)(CKEvent *))handler
{

    RACDisposable *dsp = [[[CKDispatcher sharedDispatcher] rac_addObserverForEventName:name] subscribeNext:^(CKEvent *event) {
        handler(event);
    }];
    [[self rac_deallocDisposable] addDisposable:dsp];
}

- (CKEvent *)inlineEvent:(CKEvent *)event
{
    return [self inlineEvent:event forDomain:event.name];
}

- (CKEvent *)inlineEvent:(CKEvent *)event forDomain:(NSString *)domain
{
    if (![self.eventDict objectForKey:event.name]) {
        [self.eventDict setObject:@YES forKey:event.name];
        @weakify(self);
        [self observeEventForName:domain handler:^(CKEvent *event) {
            @strongify(self);
            [self triggerEvent:event];
        }];
    }
    return event;
}

#pragma mark - Trigger
- (void)triggerEvent:(CKEvent *)event
{
    [self triggerEvent:event forDomain:event.name];
}

- (void)triggerEvent:(CKEvent *)event forDomain:(NSString *)domain
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
