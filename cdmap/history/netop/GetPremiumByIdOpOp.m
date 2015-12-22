#import "GetPremiumByIdOpOp.h"

@implementation GetPremiumByIdOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/premium/result/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *premiumlist = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"premiumlist"]) {
        InsPremium *obj = [InsPremium createWithJSONDict:curDict];
        [premiumlist addObject:obj];
    }
    self.rsp_premiumlist = premiumlist;
    self.rsp_tip = dict[@"tip"];
	
    return self;
}

@end

