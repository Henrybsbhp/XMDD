//
//  HKOtherOrder.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "HKOtherOrder.h"
#import "XiaoMa.h"

@implementation HKOtherOrder

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp)
    {
        return nil;
    }
    HKOtherOrder * order = [HKOtherOrder new];
    order.prodLogo = rsp[@"prodlogo"];
    order.prodName = [rsp stringParamForName:@"prodname"];
    order.prodDesc = [rsp stringParamForName:@"proddesc"];
    order.originPrice = [rsp stringParamForName:@"originprice"];
    order.couponPrice = [rsp stringParamForName:@"couponprice"];
    order.fee = [rsp floatParamForName:@"fee"];
    order.payedTime = [rsp[@"payedtime"] longLongValue];
    order.tradeType = [rsp stringParamForName:@"tradetype"];
    order.payDesc = [rsp stringParamForName:@"paydesc"];
    order.oId = [rsp integerParamForName:@"oid"];
    
    return order;
}

@end
