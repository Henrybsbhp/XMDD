#import "GetCooperationClaimBankcardOp.h"

@implementation GetCooperationClaimBankcardOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/claim/bankcard/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_cardlist = dict[@"cardlist"];
	
    return self;
}

@end

