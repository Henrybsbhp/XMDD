//
//  Shop.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTShop.h"
#import "NSDate+DateForText.h"

@implementation ChargeContent

+ (instancetype)chargeContentWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    ChargeContent * content = [[ChargeContent alloc] init];
    content.amount = [rsp doubleParamForName:@"amount"];
    content.paymentChannelType = (PaymentChannelType)[rsp integerParamForName:@"channel"];
    return content;
}

@end

@implementation JTShopService

+ (instancetype)shopServiceWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    JTShopService * service = [[JTShopService alloc] init];
    service.serviceID = rsp[@"serviceid"];
    service.serviceName = [rsp stringParamForName:@"name"];
    service.serviceDescription = [rsp stringParamForName:@"description"];
    service.shopServiceType = (ShopServiceType)[rsp integerParamForName:@"category"];
    NSArray * array = rsp[@"rates"];
    NSMutableArray * t = [NSMutableArray array];
    for (NSDictionary * dict in array)
    {
        [t addObject:[ChargeContent chargeContentWithJSONResponse:dict]];
        
    }
    service.chargeArray = [NSArray arrayWithArray:t];
    service.contractprice = [rsp doubleParamForName:@"contractprice"];
    service.origprice = [rsp doubleParamForName:@"origprice"];
    service.oldOriginPrice = [rsp doubleParamForName:@"oldoriginprice"];
    
    return service;
}

#pragma mark - CKItemDelegate
- (id<NSCopying>)key {
    return self.serviceID;
}

- (instancetype)setKey:(id<NSCopying>)key {
    return self;
}

@end

@implementation JTShopComment

+ (instancetype)shopCommentWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    JTShopComment * comment = [[JTShopComment alloc] init];
    comment.nickname = [rsp stringParamForName:@"nickname"];
    comment.avatarUrl = [rsp stringParamForName:@"avatar"];
    comment.rate = [rsp integerParamForName:@"rate"];
    comment.comment = [rsp stringParamForName:@"comment"];
    comment.time = [NSDate dateWithUTS:rsp[@"time"]];
    comment.serviceName = [rsp stringParamForName:@"servicename"];
    
    return comment;
}

@end

@implementation JTShop

+ (instancetype)shopWithJSONResponse:(NSDictionary *)rsp
{
    if ((!rsp) && ([rsp isKindOfClass:[NSDictionary class]]))
    {
        return nil;
    }
    JTShop * shop = [[JTShop alloc] init];
    shop.shopID  = rsp[@"shopid"];
    shop.shopName = rsp[@"name"];
    shop.picArray = rsp[@"pics"];
    shop.shopRate = [rsp doubleParamForName:@"rate"];
    shop.shopAddress = rsp[@"address"];
    shop.shopLongitude = [rsp doubleParamForName:@"longitude"];
    shop.shopLatitude = [rsp doubleParamForName:@"latitude"];
    shop.shopPhone = rsp[@"phone"];
    shop.openHour = rsp[@"openhour"];
    shop.closeHour = rsp[@"closehour"];
    shop.txnumber = [rsp integerParamForName:@"txnumber"];
    shop.announcement = [rsp stringParamForName:@"note"];
    shop.ratenumber = [rsp integerParamForName:@"ratenumber"];
    shop.isVacation = [rsp numberParamForName:@"isvacation"];
    shop.allowABC = [rsp boolParamForName:@"abcbanksupport"];
    shop.shopServiceArray = [rsp[@"services"] arrayByMapFilteringOperator:^id(id obj) {
        return [JTShopService shopServiceWithJSONResponse:obj];
    }];
    shop.maintenanceServiceArray = [rsp[@"byservices"] arrayByMapFilteringOperator:^id(id obj) {
        return [JTShopService shopServiceWithJSONResponse:obj];
    }];
    shop.beautyServiceArray = [rsp[@"mrservices"] arrayByMapFilteringOperator:^id(id obj) {
        return [JTShopService shopServiceWithJSONResponse:obj];
    }];
    shop.maintenanceRateNumber = [rsp integerParamForName:@"byrate"];
    shop.beautyRateNumber = [rsp integerParamForName:@"mrrate"];
    shop.maintenanceCommentNumber = [rsp integerParamForName:@"byratenumber"];
    shop.beautyCommentNumber = [rsp integerParamForName:@"mrratenumber"];
    return shop;
}

- (BOOL)isInBusinessHours {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    
    NSDate * nowDate = [NSDate date];
    NSString * transStr = [formatter stringFromDate:nowDate];
    NSDate * transDate = [formatter dateFromString:transStr];
    
    NSDate * beginDate = [formatter dateFromString:self.openHour];
    NSDate * endDate = [formatter dateFromString:self.closeHour];
    
    return (transDate == [transDate earlierDate:beginDate]) || (transDate == [transDate laterDate:endDate]) ? NO : YES;
}

- (NSString *)descForBusinessStatus {
    if ([self.isVacation integerValue] == 1) {
        return @"暂停营业";
    }
    return [self isInBusinessHours] ? @"营业中" : @"已休息";
}

- (NSArray *)filterShopServiceByType:(ShopServiceType)type {
    return [self.shopServiceArray arrayByFilteringOperator:^BOOL(JTShopService *service) {
        return service.shopServiceType == type;
    }];
}

- (instancetype)setKey:(id<NSCopying>)key {
    return self;
}

- (id<NSCopying>)key {
    return self.shopID;
}

@end
