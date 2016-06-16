#import "PayCooperationContractOrderOp.h"

@implementation PayCooperationContractOrderOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/contract/order/pay";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_contractid forKey:@"contractid"];
    [params safetySetObject:self.req_proxybuy ? @(1):@(0) forKey:@"proxybuy"];
    [params safetySetObject:self.req_cids forKey:@"cid"];
    [params safetySetObject:@(self.req_paychannel) forKey:@"paychannel"];
    [params safetySetObject:self.req_inscomp forKey:@"inscomp"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_total = [dict[@"total"] floatValue];
    self.rsp_tradeno = dict[@"tradeno"];
    self.rsp_notifyUrlStr = dict[@"notifyurl"];
	self.rsp_payInfoModel = [PayInfoModel payInfoWithJSONResponse:dict[@"payinfo"]];
    return self;
}

@end

