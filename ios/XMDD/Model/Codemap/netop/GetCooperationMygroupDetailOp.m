#import "GetCooperationMygroupDetailOp.h"

@implementation GetCooperationMygroupDetailOp

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
    NSMutableArray *members = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"members"]) {
        MutualInsMemberInfo *obj = [MutualInsMemberInfo createWithJSONDict:curDict];
        [members addObject:obj];
    }
    self.rsp_members = members;
    self.rsp_timeperiod = dict[@"timeperiod"];
    self.rsp_selfstatusdesc = dict[@"selfstatusdesc"];
    self.rsp_barstatus = [dict[@"barstatus"] intValue];
    self.rsp_status = [dict[@"status"] intValue];
    self.rsp_contractid = dict[@"contractid"];
    self.rsp_timetip = dict[@"timetip"];
    self.rsp_totalpoolamt = [dict[@"totalpoolamt"] floatValue];
    self.rsp_presentpoolamt = [dict[@"presentpoolamt"] floatValue];
    self.rsp_lefttime = [dict[@"lefttime"] longLongValue];
    self.rsp_pricebuttonflag = [dict[@"pricebuttonflag"] intValue];
    self.rsp_buttonname = dict[@"buttonname"];
    self.rsp_ifgroupowner = [dict[@"ifgroupowner"] boolValue];
    self.rsp_ifownerhascar = [dict[@"ifownerhascar"] boolValue];
    self.rsp_groupid = dict[@"groupid"];
    self.tempTimetag = [[NSDate date] timeIntervalSince1970];
    self.rsp_groupname = dict[@"groupname"];
    self.rsp_type = [dict[@"type"] intValue];
    self.rsp_pricebuttonname = dict[@"pricebuttonname"];
    self.rsp_invitebtnflag = [dict[@"invitebtnflag"] intValue];
    self.rsp_claimbtnflag = [dict[@"claimbtnflag"] intValue];
    self.rsp_contracturl = dict[@"contracturl"];


    return self;
}

- (NSString *)description
{
    return @"查看团的详情";
}
@end

