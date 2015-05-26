//
//  FavoriteModel.m
//  HappyTrain
//
//  Created by icopy on 15/1/10.
//  Copyright (c) 2015年 jtang. All rights reserved.
//

#import "FavoriteModel.h"

#import "GetUserFavoriteOp.h"
#import "AddUserFavoriteOp.h"
#import "DeleteUserFavoriteOp.h"


@interface FavoriteModel()
{
    NSArray * _favoritesArray;
}

@end


@implementation FavoriteModel
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _favoritesArray = [[NSArray alloc] init];
        [[self rac_requestData] subscribeNext:^(id x) {
            
        }];
    }
    return self;
}

- (RACSignal *)rac_requestData
{
    return [[[[GetUserFavoriteOp operation] rac_postRequest] doNext:^(id x) {
        
        /// inject side effect
        NSLog(@"We are in");
    }] map:^id(GetUserFavoriteOp * op) {
        
        // 这里需要对新返回的数据进行处理
        _favoritesArray = op.rsp_shopArray;
        return _favoritesArray;
    }];
}

- (RACSignal *) rac_addFavorite:(JTShop *)shop
{
    AddUserFavoriteOp * op = [[AddUserFavoriteOp alloc] init];
    op.shopid = shop.shopID;
    
    return [[op rac_postRequest] doNext:^(AddUserFavoriteOp * addOp) {
        
        // 找一下，是否已经有相应的商品了
        JTShop * s = [self getFavoriteWithID:shop.shopID];
        
        // 如果没有，则加入收藏夹列表
        if (s == nil) {
            _favoritesArray = [_favoritesArray arrayByAddingObject:shop];

            [self updateModelWithData:_favoritesArray];
            [self setNeedUpdateModel]; // 由于添加购物车，并无详细产品信息，因此需要设置为需要更新
        }
    }];
    
}

- (RACSignal *) rac_removeFavorite:(NSArray *)shopArray
{
    DeleteUserFavoriteOp * op = [DeleteUserFavoriteOp operation];
    op.shopArray = shopArray;
    
    return [[op rac_postRequest] doNext:^(DeleteUserFavoriteOp * removeOp) {
        
        // 修改现有的Array
        for (NSNumber * shopId in shopArray)
        {
            _favoritesArray = [_favoritesArray arrayByFilteringOperator:^BOOL(JTShop * shop) {
                return ![shop.shopID isEqualToNumber:shopId];
            }];
        }
        
        [self updateModelWithData:_favoritesArray];
    }];
}
     
- (JTShop *) getFavoriteWithID: (NSNumber *) productID
{
    return [_favoritesArray firstObjectByFilteringOperator:^BOOL(JTShop * shop){
        
        return [shop.shopID isEqualToNumber:productID];
    }];
}

- (void) resetData
{
    _favoritesArray = nil;
    [super resetData];
}
@end
