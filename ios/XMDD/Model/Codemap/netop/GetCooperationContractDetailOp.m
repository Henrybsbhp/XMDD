#import "GetCooperationContractDetailOp.h"

@implementation GetCooperationContractDetailOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/contract/detail/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_contractid forKey:@"contractid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj[@"contractorder"];
    self.rsp_contractorder = [MutualInsContract createWithJSONDict:dict];
	
    return self;
}

- (NSString *)description
{
    return @"互助协议查看";
}
@end

