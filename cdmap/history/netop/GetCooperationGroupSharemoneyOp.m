#import "GetCooperationGroupSharemoneyOp.h"

@implementation GetCooperationGroupSharemoneyOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/sharemoney/detail/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_totalpoolamt = dict[@"totalpoolamt"];
    self.rsp_presentpoolamt = dict[@"presentpoolamt"];
    self.rsp_insstarttime = dict[@"insstarttime"];
    self.rsp_insendtime = dict[@"insendtime"];
    self.rsp_tip = dict[@"tip"];
    self.rsp_presentpoolpresent = dict[@"presentpoolpresent"];
	
    return self;
}

@end

