#import "ApplyCooperationGroupOp.h"

@implementation ApplyCooperationGroupOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/apply";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_name = dict[@"name"];
	
    return self;
}

@end

