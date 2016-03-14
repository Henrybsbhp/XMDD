#import "GetCooperationMygroupDetailOpOp.h"

@implementation GetCooperationMygroupDetailOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/mygroup/detail/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_members = [MutualInsMemberInfo createWithJSONDict:dict];
    self.rsp_timeperiod = dict[@"timeperiod"];
    self.rsp_selfstatusdesc = dict[@"selfstatusdesc"];
	
    return self;
}

@end

