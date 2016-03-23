#import "ApplyCooperationGroupJoinOp.h"

@implementation ApplyCooperationGroupJoinOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/join/apply";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];
    [params safetySetObject:self.req_carid forKey:@"carid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_memberid = dict[@"memberid"];
	
    return self;
}

@end

