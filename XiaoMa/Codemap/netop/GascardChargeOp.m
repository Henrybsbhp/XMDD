#import "GascardChargeOp.h"

@implementation GascardChargeOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascard/charge";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_gid forKey:@"gid"];
    [params safetySetObject:@(self.req_amount) forKey:@"amount"];
    [params safetySetObject:@(self.req_paychannel) forKey:@"paychannel"];
    [params safetySetObject:self.req_vcode forKey:@"vcode"];
    [params safetySetObject:self.req_orderid forKey:@"orderid"];
    [params safetySetObject:self.req_needinvoice ? @1:@0 forKey:@"bill"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_tradeid = dict[@"tradeid"];
    self.rsp_orderid = dict[@"orderid"];
    self.rsp_total = [dict[@"total"] intValue];
    self.rsp_couponmoney = [dict[@"couponmoney"] intValue];
	
    return self;
}

@end

