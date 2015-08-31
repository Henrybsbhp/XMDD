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
    order.licencenumber = rsp[@"licencenumber"];
    order.policy = [HKInsurance insuranceWithJSONResponse:rsp[@"policy"]];
    order.validperiod = rsp[@"validperiod"];
    order.paychannel = [rsp integerParamForName:@"paychannel"];
    order.insdeliveryno = rsp[@"insdeliveryno"];
    order.insdeliverycomp = rsp[@"insdeliverycomp"];
    order.status = [rsp integerParamForName:@"status"];
    order.lstupdatetime = [NSDate dateWithD14Text:rsp[@"lstupdatetime"]];
    order.instype = [rsp integerParamForName:@"instype"];
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

- (NSString *)descForCurrentInstype
{
    if (self.instype == 2) {
        return @"小马达达保险";
    }
    return self.inscomp;
}

- (NSString *)descForCurrentStatus
{
    return @"保单已寄出";
}

- (NSString *)generateContent
{
    return @"购买一年保险";
}

@end
