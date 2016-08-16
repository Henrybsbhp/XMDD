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

- (void)resetForMyUser:(JTUser *)user {
    self.collections = nil;
    if (user) {
        [[self fetchAllCollections] subscribed];
    }
}

- (RACSignal *)fetchAllCollections {
    @weakify(self);
    self.loadingCollectionsSignal = [[[GetUserFavoriteV2Op operation] rac_postRequest] doNext:^(GetUserFavoriteV2Op *op) {
        @strongify(self);
        self.collections = [CKList listWithArray:op.rsp_shopArray];
    }];
    return self.loadingCollectionsSignal;
}

- (RACSignal *)addCollection:(JTShop *)shop {
    AddUserFavoriteOp *op = [AddUserFavoriteOp operation];
    op.shopid = shop.shopID;
    
    return [[[op rac_postRequest] catch:^RACSignal *(NSError *error) {
        
        if (error.code == 7002) {
            return [RACSignal return:nil];
        }
        return [RACSignal error:error];
    }] doNext:^(id x) {
        
        [self.collections removeObjectForKey:x];
    }];
}

- (RACSignal *)removeCollections:(NSArray *)shops {
    DeleteUserFavoriteOp * op = [DeleteUserFavoriteOp operation];
    op.shopArray = shops;
    
    return [[op rac_postRequest] doNext:^(id x) {
        for (JTShop *shop in shops) {
            [self.collections removeObjectForKey:shop.shopID];
        }
    }];
}


@end
