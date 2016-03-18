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
    self.rsp_members = [MutualInsMemberInfo createWithJSONDict:dict];
    self.rsp_timeperiod = dict[@"timeperiod"];
    self.rsp_selfstatusdesc = dict[@"selfstatusdesc"];
    self.rsp_barstatus = [dict integerParamForName:@"barstatus"];
    self.rsp_status = [dict integerParamForName:@"status"];
    self.rsp_contractid = dict[@"contractid"];
    self.rsp_timetip = dict[@"timetip"];
    self.rsp_totalpoolamt = [dict floatParamForName:@"totalpoolamt"];
    self.rsp_presentpoolamt = [dict floatParamForName:@"presentpoolamt"];
    self.rsp_lefttime = dict[@"lefttime"];
    self.rsp_buttonname = dict[@"buttonname"];
    self.rsp_ifgroupowner = [dict boolParamForName:@"ifgroupowner"];
    self.rsp_groupid = dict[@"groupid"];
    
    return self;
}

@end

