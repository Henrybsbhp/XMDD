//
//  ShopDetailStore.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKBaseStore.h"
#import "JTShop.h"
#import "GetShopRatesV2Op.h"

@interface ShopDetailStore : CKBaseStore
@property (nonatomic, strong, readonly) JTShop *shop;
@property (nonatomic, strong, readonly) CKList *serviceGroups;
@property (nonatomic, strong, readonly) CKDict *selectedServices;
@property (nonatomic, strong, readonly) CKList *commentGroups;
@property (nonatomic, strong) CKList *selectedServiceGroup;
@property (nonatomic, strong) RACSignal *reloadAllCommentsSignal;

- (void)resetDataWithShop:(JTShop *)shop withSelectedServiceType:(ShopServiceType)type;
+ (instancetype)fetchOrCreateStoreByShopID:(NSNumber *)shopid;
+ (instancetype)fetchExistsStoreByShopID:(NSNumber *)shopid;

//// 服务相关
+ (NSString *)serviceGroupDescForServiceType:(ShopServiceType)type;
+ (ShopServiceType)serviceTypeForServiceGroup:(CKList *)group;
- (ShopServiceType)currentGroupServcieType;
- (void)selectServiceGroup:(CKList *)group;
- (void)selectService:(JTShopService *)service;
- (JTShopService *)currentSelectedService;
- (NSNumber *)serviceGroupKeyForServiceType:(ShopServiceType)type;
- (NSString *)serviceGroupDescForServiceGroup:(CKList *)group;

//// 评论相关
- (void)fetchAllCommentGroups;
- (CKList *)currentCommentList;

//// 其他
+ (NSString *)markupStringWithOldPrice:(double)price1 curPrices:(double)price2;
- (NSString *)stringWithAppendSpace:(NSString *)note andWidth:(CGFloat)width;

@end
