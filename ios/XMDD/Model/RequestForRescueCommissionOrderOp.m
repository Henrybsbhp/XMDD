//
//  RequestForRescueCommissionOrderOp.m
//  XMDD
//
//  Created by St.Jimmy on 24/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "RequestForRescueCommissionOrderOp.h"

@implementation RequestForRescueCommissionOrderOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/rescue/pay/rescueservice";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_applyID forName:@"applyid"];
    [params addParam:@(self.req_payChannel) forName:@"paychannel"];
    [params addParam:self.req_payAmount forName:@"payamount"];
    [params addParam:self.req_serviceName forName:@"servicename"];
    [params addParam:self.req_licenseNumber forName:@"licensenumber"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]]) {
        self.rsp_tradeID = rspObj[@"tradeid"];
        self.rsp_payInfoModel = [PayInfoModel payInfoWithJSONResponse:rspObj[@"payinfo"]];
    } else {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
