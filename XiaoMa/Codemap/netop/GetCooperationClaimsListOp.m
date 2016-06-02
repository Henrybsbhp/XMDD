#import "GetCooperationClaimsListOp.h"

@implementation GetCooperationClaimsListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/claims/list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_gid forKey:@"gid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *claimlist = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"claimlist"]) {
        MutualInsClaimInfo *obj = [MutualInsClaimInfo createWithJSONDict:curDict];
        [claimlist addObject:obj];
    }
    self.rsp_claimlist = claimlist;
	
    return self;
}

@end

