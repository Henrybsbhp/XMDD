#import "GetGaschargeInfoOp.h"

@implementation GetGaschargeInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascard/chargedinfo/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_gid forKey:@"gid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_availablechargeamt = dict[@"availablechargeamt"];
    self.rsp_couponedmoney = dict[@"couponedmoney"];
	
    return self;
}

@end

