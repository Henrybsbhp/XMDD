//
//  GlobalStoreManager.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GlobalStoreManager.h"

@implementation GlobalStoreManager

+ (instancetype)sharedManager {
    static GlobalStoreManager *g_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_manager = [[self alloc] init];
    });
    return g_manager;
}

- (void)setupGlobalStores {
    self.collectionStore = [MyCollectionStore fetchOrCreateStore];
    self.configStore = [ConfigStore fetchOrCreateStore];
    [self.configStore loadDefaultSystemConfig];
    [[self.configStore fetchSystemConfig] subscribed];
}

@end
