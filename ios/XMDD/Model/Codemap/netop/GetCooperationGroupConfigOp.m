#import "GetCooperationGroupConfigOp.h"

@implementation GetCooperationGroupConfigOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/config/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_isexit = [dict[@"isexit"] intValue];
    self.rsp_invitebtnflag = [dict[@"invitebtnflag"] intValue];
    self.rsp_helpurl = dict[@"helpurl"];
    self.rsp_claimbtnflag = [dict[@"claimbtnflag"] intValue];
    self.rsp_huzhulstupdatetime = [dict[@"huzhulstupdatetime"] longLongValue];
    self.rsp_newslstupdatetime = [dict[@"newslstupdatetime"] longLongValue];
    self.rsp_groupname = dict[@"groupname"];
    self.rsp_status = [dict[@"status"] intValue];
    self.rsp_contractid = dict[@"contractid"];
    self.rsp_ifgroupowner = [dict[@"ifgroupowner"] intValue];
    self.rsp_isdelete = [dict[@"isdelete"] intValue];
    self.rsp_showselfflag = [dict[@"showselfflag"] intValue];
	
    return self;
}

@end

