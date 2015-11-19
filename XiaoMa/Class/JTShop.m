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
    content.amount = [rsp floatParamForName:@"amount"];
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
    service.contractprice = [rsp floatParamForName:@"contractprice"];
    service.origprice = [rsp floatParamForName:@"origprice"];
    
    return service;
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
    shop.shopRate = [rsp floatParamForName:@"rate"];
    shop.shopAddress = rsp[@"address"];
    shop.shopLongitude = [rsp doubleParamForName:@"longitude"];
    shop.shopLatitude = [rsp doubleParamForName:@"latitude"];
    shop.shopPhone = rsp[@"phone"];
    shop.openHour = rsp[@"openhour"];
    shop.closeHour = rsp[@"closehour"];
    shop.txnumber = [rsp integerParamForName:@"txnumber"];
    shop.announcement = [rsp stringParamForName:@"note"];
    shop.ratenumber = [rsp integerParamForName:@"ratenumber"];
    NSArray * array = rsp[@"services"];
    NSMutableArray * t = [NSMutableArray array];
    for (NSDictionary * dict in array)
    {
        [t addObject:[JTShopService shopServiceWithJSONResponse:dict]];
    }
    shop.shopServiceArray = [NSArray arrayWithArray:t];
    shop.allowABC = [rsp boolParamForName:@"abcbanksupport"];
    return shop;
}

@end
