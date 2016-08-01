#import "AddCooperationClaimBankcardOp.h"

@implementation AddCooperationClaimBankcardOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/claim/bankcard/add";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_cardno forKey:@"cardno"];
    [params safetySetObject:self.req_issuebank forKey:@"issuebank"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_cardid = dict[@"cardid"];
	
    return self;
}

- (NSString *)description
{
    return @"添加一张理赔银行卡";
}
@end

