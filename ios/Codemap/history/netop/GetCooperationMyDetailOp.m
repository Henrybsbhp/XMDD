#import "GetCooperationMyDetailOp.h"

@implementation GetCooperationMyDetailOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/my/detail/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_licensenumbe = dict[@"licensenumbe"];
    self.rsp_carlogourl = dict[@"carlogourl"];
    self.rsp_status = [dict[@"status"] intValue];
    self.rsp_fee = dict[@"fee"];
    self.rsp_feedesc = dict[@"feedesc"];
    self.rsp_helpfee = dict[@"helpfee"];
    self.rsp_claimcnt = [dict[@"claimcnt"] intValue];
    self.rsp_claimfee = dict[@"claimfee"];
    self.rsp_insstarttime = dict[@"insstarttime"];
    self.rsp_insendtime = dict[@"insendtime"];
    self.rsp_sharemoney = dict[@"sharemoney"];
    self.rsp_servicefee = dict[@"servicefee"];
    self.rsp_forcefee = dict[@"forcefee"];
    self.rsp_shiptaxfee = dict[@"shiptaxfee"];
    self.rsp_tip = dict[@"tip"];
    self.rsp_contracturl = dict[@"contracturl"];
	
    return self;
}

@end

