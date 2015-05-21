//
//  FavoriteModel.h
//  HappyTrain
//
//  Created by icopy on 15/1/10.
//  Copyright (c) 2015年 jtang. All rights reserved.
//

#import "BaseModel.h"
#import "JTShop.h"

@interface FavoriteModel : BaseModel

@property (nonatomic, readonly, getter=getFavoritesArray) NSArray * favoritesArray;

- (RACSignal *)rac_addFavorite: (JTShop *) shop;
- (RACSignal *)rac_removeFavorite: (NSNumber *) shopid;
- (JTShop *) getFavoriteWithID: (NSNumber *) shopid;

@end
