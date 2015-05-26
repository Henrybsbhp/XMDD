//
//  HKServiceOrder.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKServiceOrder.h"
#import "XiaoMa.h"

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
    order.txtime = [NSDate dateWithD14Text:rsp[@"txtime"]];
    order.rating = [rsp floatParamForName:@"rating"];
    order.comment = rsp[@"comment"];
    order.ratetime = [NSDate dateWithUTS:rsp[@"ratetime"]];
    order.tradetime = [rsp[@"tradetime"] longLongValue];
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
        default:
            break;
    }
    return payment;
}

@end
