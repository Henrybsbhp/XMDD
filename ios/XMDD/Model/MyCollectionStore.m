//
//  MyCollectionStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MyCollectionStore.h"
#import "GetUserFavoriteV2Op.h"

@implementation MyCollectionStore

- (void)resetForMyUser:(JTUser *)user {
    self.collectionList = nil;
    if (user) {
        [self fetchAllCollections];
    }
}

- (RACSignal *)fetchAllCollections {
    @weakify(self);
    self.loadingCollectionsSignal = [[[GetUserFavoriteV2Op operation] rac_postRequest] doNext:^(GetUserFavoriteV2Op *op) {
        @strongify(self);
        self.collectionList = [CKList listWithArray:op.rsp_shopArray];
    }];
    return self.loadingCollectionsSignal;
}
@end
