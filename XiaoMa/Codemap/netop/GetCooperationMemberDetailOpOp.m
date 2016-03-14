#import "GetCooperationMemberDetailOpOp.h"

@implementation GetCooperationMemberDetailOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/member/detail/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_licensenumber = dict[@"licensenumber"];
    self.rsp_phone = dict[@"phone"];
    self.rsp_carbrand = dict[@"carbrand"];
    self.rsp_sharemoney = [dict[@"sharemoney"] floatValue];
    self.rsp_rate = [dict[@"rate"] intValue];
    self.rsp_returnmoney = [dict[@"returnmoney"] floatValue];
	
    return self;
}

@end

