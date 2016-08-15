//
//  HKServiceOrder.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKServiceOrder.h"
#import "Xmdd.h"

@implementation HKServiceOrder

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKServiceOrder * order = [HKServiceOrder new];
    order.orderid = rsp[@"orderid"];
    order.serviceid = rsp[@"serviceid"];
    order.shop = [JTShop shopWithJSONResponse:rsp[@"shop"]];
    order.licencenumber = rsp[@"licencenumber"];
    order.paychannel = [rsp integerParamForName:@"paychannel"];
    order.paydesc = rsp[@"paydesc"];
    order.txtime = [NSDate dateWithD14Text:rsp[@"txtime"]];
    order.rating = [rsp floatParamForName:@"rating"];
    order.comment = rsp[@"comment"];
    order.ratetime = [NSDate dateWithUTS:rsp[@"ratetime"]];
    order.tradetime = [rsp[@"tradetime"] longLongValue];
    order.fee = [rsp[@"fee"] floatValue];
    order.servicename = rsp[@"servicename"];
    order.serviceprice = [rsp[@"serviceprice"] floatValue];
    order.orderPic = [rsp stringParamForName:@"avatar"];
    order.nickName = [rsp stringParamForName:@"nickname"];
    order.status = [rsp[@"status"] integerValue];
    order.statusDesc = rsp[@"statusdesc"];
    order.serviceDesc = rsp[@"servicedesc"];
    order.serviceType = [rsp integerParamForName:@"category"];
    return order;
}

- (JTShopService *)currentService
{
    NSNumber *serviceid = self.serviceid;
    return [self.shop.shopServiceArray firstObjectByFilteringOperator:^BOOL(JTShopService *obj) {
        return [obj.serviceID isEqualToNumber:serviceid];
    }];
}

- (NSString *)paymentForCurrentChannel
{
    NSString *payment;
    switch (self.paychannel) {
        case PaymentChannelCoupon:
            payment = @"用券支付";
            break;
        case PaymentChannelAlipay:
            payment = @"支付宝支付";
            break;
        case PaymentChannelWechat:
            payment = @"微信支付";
            break;
        case PaymentChannelCZBCreditCard:
            payment = @"信用卡支付";
            break;
        default:
            break;
    }
    return payment;
}

@end
