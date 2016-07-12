#import "GascardChargeByStagesOp.h"

@implementation GascardChargeByStagesOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/order/gascard/fqjy/charge";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_cardid forKey:@"cardid"];
    [params safetySetObject:@(self.req_bill) forKey:@"bill"];
    [params safetySetObject:self.req_pkgid forKey:@"pkgid"];
    [params safetySetObject:@(self.req_permonthamt) forKey:@"permonthamt"];
    [params safetySetObject:@(self.req_paychannel) forKey:@"paychannel"];
    [params safetySetObject:self.req_cid forKey:@"cid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_tradeid = dict[@"tradeid"];
    self.rsp_orderid = dict[@"orderid"];
    self.rsp_total = [dict[@"total"] floatValue];
    self.rsp_couponmoney = [dict[@"couponmoney"] floatValue];
    self.rsp_tip = dict[@"tip"];
    self.rsp_notifyUrlStr = dict[@"notifyurl"];
    self.rsp_payInfoModel = [PayInfoModel payInfoWithJSONResponse:dict[@"payinfo"]];
	
    return self;
}


- (NSString *)description
{
    return @"分期加油";
}
@end

