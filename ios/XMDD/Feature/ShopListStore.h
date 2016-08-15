//
//  ShopListStore.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CKBaseStore.h"
#import "GetShopByDistanceV2Op.h"
#import "GetShopByNameV2Op.h"
#import "JTShop.h"

@interface ShopListStore : CKBaseStore
/// 商户列表分组<list of JTShop>
@property (nonatomic, strong, readonly) CKList *shopList;
@property (nonatomic, assign, readonly) ShopServiceType serviceType;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;

- (instancetype)initWithServiceType:(ShopServiceType)type;
/// (WillSendNext:GetShopByDistanceV2Op)
- (RACSignal *)fetchShopListByDistanceWithLocationErrorHandler:(void(^)(NSError *))handler;
/// (WillSendNext:GetShopByDistanceV2Op)
- (RACSignal *)fetchMoreShopListByDistance;
/// (WillSendNext:GetShopByNameV2Op)
- (RACSignal *)fetchShopListByName:(NSString *)name;
/// (WillSendNext:GetShopByNameV2Op)
- (RACSignal *)fetchMoreShopListByName;

+ (NSString *)descForShopServiceWithService:(JTShopService *)service andShop:(JTShop *)shop;
+ (NSString *)markupForShopServicePrice:(JTShopService *)service;

@end
