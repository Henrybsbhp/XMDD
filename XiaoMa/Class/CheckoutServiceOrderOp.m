//
//  CheckoutServiceOrderOp.m
//  XiaoMa
//
//  Created by jt on 15-4-18.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CheckoutServiceOrderOp.h"

@implementation CheckoutServiceOrderOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/order/service/checkout";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.serviceid forName:@"serviceid"];
    [params addParam:self.licencenumber forName:@"licencenumber"];
    [params addParam:self.cid forName:@"cid"];
    [params addParam:@(self.paychannel) forName:@"paychannel"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_orderid = rspObj[@"tradeid"];
        self.rsp_price = [rspObj floatParamForName:@"total"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
