//
//  CheckoutServiceOrderV2Op.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CheckoutServiceOrderV2Op.h"

@implementation CheckoutServiceOrderV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/order/service/v2/checkout";
    
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
    [params addParam:self.carbrand forName:@"carbrand"];
    [params addParam:[NSString stringWithFormat:@"%f", self.coordinate.longitude] forName:@"longitude"];
    [params addParam:[NSString stringWithFormat:@"%f", self.coordinate.latitude] forName:@"latitude"];
    
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
