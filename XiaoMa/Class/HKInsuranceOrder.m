//
//  HKInsuranceOrder.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKInsuranceOrder.h"
#import "XiaoMa.h"

@implementation HKInsuranceOrder

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKInsuranceOrder *order  = [HKInsuranceOrder new];
    order.orderid = rsp[@"orderid"];
    order.policyholder = rsp[@"policyholder"];
    order.idcard = rsp[@"idcard"];
    order.inscomp = rsp[@"inscomp"];
    order.serviceName = rsp[@"servicename"];
    order.licencenumber = rsp[@"licencenumber"];
    order.policy = [HKInsurance insuranceWithJSONResponse:rsp[@"policy"]];
    order.validperiod = rsp[@"validperiod"];
    order.paychannel = [rsp integerParamForName:@"paychannel"];
    order.paydesc = rsp[@"paydesc"];
    order.insdeliveryno = rsp[@"insdeliveryno"];
    order.insdeliverycomp = rsp[@"insdeliverycomp"];
    order.totoalpay = [rsp floatParamForName:@"totalpay"];
    order.status = [rsp integerParamForName:@"status"];
    order.lstupdatetime = [NSDate dateWithD14Text:rsp[@"lstupdatetime"]];
    order.totoalpay = [rsp floatParamForName:@"totalpay"];
    
    order.iscontainActivity = [rsp boolParamForName:@"isusedcoupon"];
    order.activityName = rsp[@"activityname"];
    order.activityTag = rsp[@"couponname"];
    order.activityType = (DiscountType)[rsp integerParamForName:@"coupontype"];
    order.activityAmount = [rsp floatParamForName:@"couponmoney"];
    return order;
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

- (NSString *)descForCurrentStatus
{
    NSString *desc;
    switch (self.status) {
        case InsuranceOrderStatusUnpaid:
            desc = @"未支付";
            break;
        case InsuranceOrderStatusPaid:
            desc = @"保单受理中";
            break;
        case InsuranceOrderStatusComplete:
            desc = @"保单已出";
            break;
        case InsuranceOrderStatusStopping:
            desc = @"停保审核中";
            break;
        case InsuranceOrderStatusStopped:
            desc = @"已停保";
            break;
        case InsranceOrderStatusClose:
            desc = @"订单已关闭";
            break;
        default:
            desc = @"订单异常";
            break;
    }
    return desc;
}

- (NSString *)generateContent
{
    return @"购买一年保险一份";
}

@end
