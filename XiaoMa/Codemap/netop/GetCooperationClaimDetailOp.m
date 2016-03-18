#import "GetCooperationClaimDetailOp.h"

@implementation GetCooperationClaimDetailOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/claim/detail";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_claimid forKey:@"claimid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_statusdesc = dict[@"statusdesc"];
    self.rsp_status = dict[@"status"];
    self.rsp_accidenttime = dict[@"accidenttime"];
    self.rsp_accidentaddress = dict[@"accidentaddress"];
    self.rsp_chargepart = dict[@"chargepart"];
    self.rsp_cardmgdesc = dict[@"cardmgdesc"];
    self.rsp_reason = dict[@"reason"];
    self.rsp_claimfee = [dict[@"claimfee"] floatValue];
    self.rsp_cardid = dict[@"cardid"];
    self.rsp_cardname = dict[@"cardname"];
    self.rsp_cardno = dict[@"cardno"];
    return self;
}

@end

