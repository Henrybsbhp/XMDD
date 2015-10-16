//
//  CheckoutServiceOrderV3Op.m
//  XiaoMa
//
//  Created by jt on 15/9/21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CheckoutServiceOrderV3Op.h"

@implementation CheckoutServiceOrderV3Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/order/service/v3/checkout";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString * cid;
    if (self.couponArray.count)
    {
        cid = [self.couponArray componentsJoinedByString:@","];
    }
    [params addParam:self.serviceid forName:@"serviceid"];
    [params addParam:self.licencenumber forName:@"licencenumber"];
    [params addParam:cid ? cid : @"" forName:@"cid"];
    [params addParam:@(self.paychannel) forName:@"paychannel"];
    [params addParam:self.carMake forName:@"make"];
    [params addParam:self.carModel forName:@"model"];
    [params addParam:[NSString stringWithFormat:@"%f", self.coordinate.longitude] forName:@"longitude"];
    [params addParam:[NSString stringWithFormat:@"%f", self.coordinate.latitude] forName:@"latitude"];
    [params addParam:self.bankCardId ? self.bankCardId : @0 forName:@"cardid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_tradeId = rspObj[@"tradeid"];
        self.rsp_price = [rspObj floatParamForName:@"total"];
        self.rsp_orderid = rspObj[@"orderid"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
