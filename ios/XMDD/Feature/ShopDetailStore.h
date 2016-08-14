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
@property (nonatomic, strong, readonly) CKList *selectedServiceGroup;
@property (nonatomic, strong, readonly) CKList *commentGroups;

- (void)resetDataWithShop:(JTShop *)shop;

//// 服务相关
+ (NSString *)serviceGroupDescForServiceType:(ShopServiceType)type;
+ (ShopServiceType)serviceTypeForServiceGroup:(CKList *)group;
- (void)selectServiceGroup:(CKList *)group;
- (void)selectService:(JTShopService *)service;
- (JTShopService *)currentSelectedService;
- (NSNumber *)serviceGroupKeyForServiceType:(ShopServiceType)type;
- (NSString *)serviceGroupDescForServiceGroup:(CKList *)group;


//// 评论相关
- (RACSignal *)fetchAllCommentGroups;
- (CKList *)currentCommentList;
- (NSInteger)currentCommentNumber;

/// 收藏相关
- (BOOL)isShopCollected;
- (RACSignal *)collectShop;
- (RACSignal *)unCollectShop;

//// 其他
+ (NSString *)markupStringWithOldPrice:(double)price1 curPrices:(double)price2;
+ (NSString *)maintenanceDesc;
- (NSString *)stringWithAppendSpace:(NSString *)note andWidth:(CGFloat)width;

@end
