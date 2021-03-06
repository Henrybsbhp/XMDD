//
//  ShopDetailStore.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailStore.h"
#import "NSNumber+Format.h"
#import "NSString+RectSize.h"

@interface ShopDetailStore ()
@property (nonatomic, strong, readonly) GetShopRatesV2Op *commentsOp;
@end

@implementation ShopDetailStore

#pragma mark - Public
+ (instancetype)fetchOrCreateStoreByShopID:(NSNumber *)shopid {
    return [self fetchOrCreateStoreForKey:[NSString stringWithFormat:@"Shop.Detail.%@", shopid]];
}

+ (instancetype)fetchExistsStoreByShopID:(NSNumber *)shopid {
    return [self fetchExistsStoreForKey:[NSString stringWithFormat:@"Shop.Detail.%@", shopid]];
}

- (void)resetDataWithShop:(JTShop *)shop withSelectedServiceType:(ShopServiceType)type {
    _shop = shop;

    CKDict *selectedServices = [[CKDict alloc] init];
    CKList *serviceGroups = [CKList list];
    if (shop.shopServiceArray.count > 0) {
        CKList *group = [[CKList listWithArray:shop.shopServiceArray] setKey:@(ShopServiceAllCarWash)];
        [serviceGroups addObject:group forKey:nil];
        selectedServices[@(ShopServiceAllCarWash)] = group[0];
        if (type == ShopServiceCarwashWithHeart) {
            JTShop *service = [[group allObjects] firstObjectByFilteringOperator:^BOOL(JTShopService *service) {
                return service.shopServiceType == ShopServiceCarwashWithHeart;
            }];
            selectedServices[@(ShopServiceAllCarWash)] = service;
        }
    }
    if ([shop.beautyServiceArray count] > 0) {
        CKList *group = [[CKList listWithArray:shop.beautyServiceArray] setKey:@(ShopServiceCarBeauty)];
        [serviceGroups addObject:group forKey:nil];
        selectedServices[@(ShopServiceCarBeauty)] = group[0];
    }
    if ([shop.maintenanceServiceArray count] > 0) {
        CKList *group = [[CKList listWithArray:shop.maintenanceServiceArray] setKey:@(ShopServiceCarMaintenance)];
        [serviceGroups addObject:group forKey:nil];
        selectedServices[@(ShopServiceCarMaintenance)] = group[0];
    }
    
    _serviceGroups = serviceGroups;
    _selectedServices = selectedServices;
    [self selectServiceGroup:serviceGroups[0]];
    _commentGroups = nil;
}

#pragma mark - Service
- (void)selectServiceGroup:(CKList *)group {
    self.selectedServiceGroup = group;
}

- (void)selectService:(JTShopService *)service {
    _selectedServices[[self serviceGroupKeyForServiceType:service.shopServiceType]] = service;
}

- (NSNumber *)serviceGroupKeyForServiceType:(ShopServiceType)type {
    if (type == ShopServiceCarwashWithHeart || type == ShopServiceCarWash) {
        return @(ShopServiceAllCarWash);
    }
    return @(type);
}

+ (NSString *)serviceGroupDescForServiceType:(ShopServiceType)type {
    switch (type) {
        case ShopServiceCarMaintenance:
            return @"小保养";
        case ShopServiceCarBeauty:
            return @"美容";
        case ShopServiceCarwashWithHeart:
            return @"精洗";
        case ShopServiceCarWash:
            return @"普洗";
        default:
            return @"洗车";
    }
}

+ (ShopServiceType)serviceTypeForServiceGroup:(CKList *)group {
    NSNumber *groupkey = (NSNumber *)group.key;
    return [groupkey integerValue];
}

- (ShopServiceType)currentGroupServcieType {
    return [ShopDetailStore serviceTypeForServiceGroup:self.selectedServiceGroup];
}

- (NSString *)serviceGroupDescForServiceGroup:(CKList *)group {
    ShopServiceType type = [(NSNumber *)group.key integerValue];
    return [ShopDetailStore serviceGroupDescForServiceType:type];
}


- (JTShopService *)currentSelectedService {
    NSNumber *groupKey = (NSNumber *)self.selectedServiceGroup.key;
    return self.selectedServices[groupKey];
}

#pragma mark - Comment
- (CKList *)currentCommentList {
    return self.commentGroups[self.selectedServiceGroup.key];
}

- (void)fetchAllCommentGroups {
    GetShopRatesV2Op * op = [GetShopRatesV2Op operation];
    op.req_shopid = self.shop.shopID;
    op.req_pageno = 1;
    op.req_serviceTypes = @"1,2,3,4";
    @weakify(self);
    self.reloadAllCommentsSignal = [[op rac_postRequest] doNext:^(GetShopRatesV2Op *op) {
        
        @strongify(self);
        _commentsOp = op;
        self.shop.carwashCommentNumber = op.rsp_carwashTotalNumber;
        self.shop.maintenanceCommentNumber = op.rsp_maintenanceTotalNumber;
        self.shop.beautyCommentNumber = op.rsp_beautyTotalNumber;
        _commentGroups = $([[CKList listWithArray:op.rsp_carwashCommentArray] setKey:@(ShopServiceAllCarWash)],
                           [[CKList listWithArray:op.rsp_maintenanceCommentArray] setKey:@(ShopServiceCarMaintenance)],
                           [[CKList listWithArray:op.rsp_beautyCommentArray] setKey:@(ShopServiceCarBeauty)]);
    }];
}

#pragma mark - Util
+ (NSString *)markupStringWithOldPrice:(double)price1 curPrices:(double)price2 {
    NSString *strPrice1 = [@(price1) priceString];
    NSString *strPrice2 = [@(price2) priceString];
    NSMutableString *markup = [NSMutableString string];
    if ([strPrice1 compare:strPrice2 options:NSNumericSearch] == NSOrderedDescending) {
        [markup appendString:
         [NSString stringWithFormat:@"<font size='12' color='#888888'>原价<strike>￥%@ </strike></font>", strPrice1]];
    }
    
    [markup appendString: [NSString stringWithFormat:@"<font size='16' color='#ff7428'>￥%@</font>", strPrice2]];
    return markup;
}

- (NSString *)stringWithAppendSpace:(NSString *)note andWidth:(CGFloat)w {
    NSString * spaceNote = note;
    for (NSInteger i = 0;i< 1000;i++)
    {
        CGSize size = [spaceNote labelSizeWithWidth:9999 font:[UIFont systemFontOfSize:13]];
        if (size.width > w)
            return spaceNote;
        spaceNote = [spaceNote append:@" "];
    }
    return spaceNote;
}

@end
