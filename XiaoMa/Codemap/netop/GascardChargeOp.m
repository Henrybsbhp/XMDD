#import "GascardChargeOp.h"
#import "PayInfoModel.h"

@implementation GascardChargeOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascard/charge";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_gid forKey:@"gid"];
    [params safetySetObject:@(self.req_amount) forKey:@"amount"];
    [params safetySetObject:self.req_cid forKey:@"cid"];
    [params safetySetObject:@(self.req_paychannel) forKey:@"paychannel"];
    [params safetySetObject:self.req_vcode forKey:@"vcode"];
    [params safetySetObject:self.req_orderid forKey:@"orderid"];
    [params safetySetObject:@(self.req_bill) forKey:@"bill"];
    [params addParam:self.req_blackbox forName:@"blackbox"];
    [params addParam:@(IOSAPPID) forName:@"os"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_tradeid = dict[@"tradeid"];
    self.rsp_orderid = dict[@"orderid"];
    self.rsp_total = [dict floatParamForName:@"total"];
    self.rsp_couponmoney = [dict floatParamForName:@"couponmoney"];
    self.rsp_notifyUrlStr = dict[@"notifyurl"];
    self.rsp_payInfoModel = [PayInfoModel payInfoWithJSONResponse:dict[@"payinfo"]];
	
    return self;
}

- (NSString *)description
{
    return @"获取油卡当月充值信息";
}
@end

