#import "PayCooperationContractOrderOpOp.h"

@implementation PayCooperationContractOrderOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/contract/order/pay";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_contractid forKey:@"contractid"];
    [params safetySetObject:self.req_proxybuy forKey:@"proxybuy"];
    [params safetySetObject:self.req_cid forKey:@"cid"];
    [params safetySetObject:self.req_paychannel forKey:@"paychannel"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_total = [dict[@"total"] floatValue];
    self.rsp_tradeno = dict[@"tradeno"];
	
    return self;
}

@end

