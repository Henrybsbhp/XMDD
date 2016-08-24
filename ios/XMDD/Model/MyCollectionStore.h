//
//  MyCollectionStore.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyUserStore.h"
#import "JTShop.h"

@interface MyCollectionStore : MyUserStore
@property (nonatomic, strong, readonly) CKList *collections;
///(sendNext: collections)
@property (nonatomic, strong, readonly) RACSubject *collectionsChanged;

- (RACSignal *)fetchAllCollections;
- (RACSignal *)addCollection:(JTShop *)shop;
- (RACSignal *)removeCollections:(NSArray *)shops;
- (BOOL)isCollectedByShopID:(NSNumber *)shopid;

@end
