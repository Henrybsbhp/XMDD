#import "GetCooperationClaimsListOpOp.h"

@implementation GetCooperationClaimsListOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/claims/list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_claimlist = [MutualInsClaimInfo createWithJSONDict:dict];
	
    return self;
}

@end

