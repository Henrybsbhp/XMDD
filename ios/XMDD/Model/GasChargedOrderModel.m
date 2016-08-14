//
//  GasChargedOrderModel.m
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GasChargedOrderModel.h"

@implementation GasChargedOrderModel

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp
{
    if (!rsp) {
        return nil;
    }
    
    GasChargedOrderModel *order = [GasChargedOrderModel new];
    order.payedTime = [rsp[@"payedtime"] longLongValue];
    order.tradeType = rsp[@"tradetype"];
    order.orderID = [rsp[@"orderid"] integerValue];
    order.cardType = [rsp[@"cardtype"] integerValue];
    order.gasCardNum = rsp[@"gascardno"];
    order.status = [rsp[@"status"] integerValue];
    order.statusDesc = rsp[@"statusdesc"];
    order.payMoney = rsp[@"paymoney"];
    order.chargeTips = rsp[@"chargetip"];
    order.chargeMoney = rsp[@"chargemoney"];
    
    return order;
}

@end
