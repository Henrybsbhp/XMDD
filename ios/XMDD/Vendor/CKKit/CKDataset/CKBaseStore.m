//
//  CKBaseStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKBaseStore.h"


@implementation CKBaseStore

+ (NSMapTable *)storeTable
{
    static NSMapTable *g_storeTable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_storeTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
    });
    return g_storeTable;
}

+ (instancetype)fetchExistsStoreForKey:(NSString *)key {
    return [[self storeTable] objectForKey:key];
}

+ (instancetype)fetchOrCreateStoreForKey:(NSString *)key {
    CKBaseStore *store = [self fetchExistsStoreForKey:key];
    if (!store) {
        store = [[self alloc] init];
        [[self storeTable] setObject:store forKey:key];
    }
    return store;
}

+ (instancetype)fetchExistsStore {
    return [self fetchExistsStoreForKey:NSStringFromClass([self class])];
}
+ (instancetype)fetchOrCreateStore {
    return [self fetchOrCreateStoreForKey:NSStringFromClass([self class])];
}

@end

