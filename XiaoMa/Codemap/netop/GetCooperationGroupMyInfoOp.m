#import "GetCooperationGroupMyInfoOp.h"

@implementation GetCooperationGroupMyInfoOp

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
    self.rsp_licensenumber = dict[@"licensenumber"];
    self.rsp_carlogourl = dict[@"carlogourl"];
    self.rsp_status = [dict[@"status"] intValue];
    self.rsp_statusdesc = dict[@"statusdesc"];
    self.rsp_fee = [dict stringParamForName:@"fee"];
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
    self.rsp_buttonname = dict[@"buttonname"];
    self.rsp_usercarid = dict[@"usercarid"];
	
    return self;
}

- (id)returnSimulateResponse {
//    return @{@"rc": @0,
//             @"licensenumber": @"浙A12345", @"status": @1, @"statusdesc": @"待完善资料",
//             @"tip": @"提交资料，通过审核后且成功支付即可加入互助", @"buttonname": @"完善资料"};
//    return @{@"rc": @0,
//             @"licensenumber": @"浙A12345", @"status": @3, @"statusdesc": @"审核中",
//             @"tip": @"您上传的资料正在审核中，请耐心等待"};
    return @{@"rc": @0,
             @"licensenumber": @"浙A12345", @"status": @5, @"statusdesc": @"待支付",
             @"tip": @"请在2016年7月23日24:00前完成支付", @"buttonname": @"前去支付",
             @"fee": @"5688.00", @"feedesc": @"订单金额", @"sharemoney": @"4788.00", @"servicefee": @"900.00",
             @"forcefee": @"783.00", @"shiptaxfee": @"500.00", @"insstarttime": @"2016-07-23 00:00",
             @"insendtime": @"2016-07-23 00:00"};
}

@end

