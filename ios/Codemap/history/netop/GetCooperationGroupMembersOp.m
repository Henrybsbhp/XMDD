#import "GetCooperationGroupMembersOp.h"

@implementation GetCooperationGroupMembersOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/groupmember/list/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];
    [params safetySetObject:@(self.req_lstupdatetime) forKey:@"lstupdatetime"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_membercnt = [dict[@"membercnt"] intValue];
    NSMutableArray *memberlist = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"memberlist"]) {
        MutualInsMemberInfo2 *obj = [MutualInsMemberInfo2 createWithJSONDict:curDict];
        [memberlist addObject:obj];
    }
    self.rsp_memberlist = memberlist;
    self.rsp_lstupdatetime = [dict[@"lstupdatetime"] longLongValue];
    self.rsp_toptip = dict[@"toptip"];
	
    return self;
}

@end

