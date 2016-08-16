//
//  MyCollectionStore.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyUserStore.h"

@interface MyCollectionStore : MyUserStore
@property (nonatomic, strong) CKList *collections;
@property (nonatomic, strong) RACSignal *loadingCollectionsSignal;

- (RACSignal *)fetchAllCollections;
- (RACSignal *)addCollection:(JTShop *)shop;
- (RACSignal *)removeCollections:(NSArray *)shops;
@end
