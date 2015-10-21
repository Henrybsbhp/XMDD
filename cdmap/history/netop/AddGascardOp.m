#import "AddGascardOp.h"

@implementation AddGascardOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascard/add";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_gascardno forKey:@"gascardno"];
    [params safetySetObject:@(self.req_cardtype) forKey:@"cardtype"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_gid = dict[@"gid"];
    self.rsp_availablechargeamt = [dict[@"availablechargeamt"] intValue];
    self.rsp_couponedmoney = [dict[@"couponedmoney"] intValue];
	
    return self;
}

@end

