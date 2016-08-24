//
//  MyCollectionStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyCollectionStore.h"
#import "GetUserFavoriteV2Op.h"
#import "AddUserFavoriteOp.h"
#import "DeleteUserFavoriteOp.h"

@implementation MyCollectionStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        _collectionsChanged = [RACSubject subject];
    }
    return self;
}

- (void)resetForMyUser:(JTUser *)user {
    _collections = nil;
    if (user) {
        [[self fetchAllCollections] subscribed];
    }
}

- (RACSignal *)fetchAllCollections {
    return [[[GetUserFavoriteV2Op operation] rac_postRequest] doNext:^(GetUserFavoriteV2Op *op) {
        _collections = [CKList listWithArray:op.rsp_shopArray];
        [self.collectionsChanged sendNext:self.collections];
    }];
}

- (RACSignal *)addCollection:(JTShop *)shop {
    AddUserFavoriteOp *op = [AddUserFavoriteOp operation];
    op.shopid = shop.shopID;
    
    return [[[op rac_postRequest] catch:^RACSignal *(NSError *error) {
        
        if (error.code == 7002) {
            return [RACSignal return:nil];
        }
        return [RACSignal error:error];
    }] doNext:^(AddUserFavoriteOp *op) {
        
        [self.collections removeObjectForKey:op.shopid];
        [self.collections insertObject:shop withKey:shop.shopID atIndex:0];
        [self.collectionsChanged sendNext:self.collections];
    }];
}

- (RACSignal *)removeCollections:(NSArray *)shops {
    DeleteUserFavoriteOp * op = [DeleteUserFavoriteOp operation];
    op.shopArray = [shops arrayByMapFilteringOperator:^id(JTShop *shop) {
        return shop.shopID;
    }];
    
    return [[op rac_postRequest] doNext:^(DeleteUserFavoriteOp *op) {
        
        for (JTShop *shop in shops) {
            [self.collections removeObjectForKey:shop.shopID];
        }
        [self.collectionsChanged sendNext:self.collections];
    }];
}

#pragma mark - Getter
- (BOOL)isCollectedByShopID:(NSNumber *)shopid {
    return self.collections[shopid] != nil;
}

@end
