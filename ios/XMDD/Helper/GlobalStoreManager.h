//
//  GlobalStoreManager.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyCollectionStore.h"
#import "ConfigStore.h"

@interface GlobalStoreManager : NSObject
@property (nonatomic, strong) MyCollectionStore *collectionStore;
@property (nonatomic, strong) ConfigStore *configStore;

+ (instancetype)sharedManager;
- (void)setupGlobalStores;

@end
