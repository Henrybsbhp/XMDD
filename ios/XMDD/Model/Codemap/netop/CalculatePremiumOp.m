#import "CalculatePremiumOp.h"

@implementation CalculatePremiumOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/premium/calculate";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];
    [params safetySetObject:self.req_inslist forKey:@"inslist"];
    [params safetySetObject:self.req_mstartdate forKey:@"mstartdate"];
    [params safetySetObject:self.req_fstartdate forKey:@"fstartdate"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.longtimeManager params:params security:YES];
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


- (NSString *)description
{
    return @"核保车辆信息更新";
}
@end

