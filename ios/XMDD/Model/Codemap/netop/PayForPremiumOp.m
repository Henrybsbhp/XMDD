#import "PayForPremiumOp.h"

@implementation PayForPremiumOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/premium/pay";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];
    [params safetySetObject:self.req_ownername forKey:@"ownername"];
    [params safetySetObject:self.req_startdate forKey:@"startdate"];
    [params safetySetObject:self.req_forcestartdate forKey:@"forcestartdate"];
    [params safetySetObject:self.req_inscomp forKey:@"inscomp"];
    [params safetySetObject:self.req_idno forKey:@"idno"];
    [params safetySetObject:self.req_ownerphone forKey:@"ownerphone"];
    [params safetySetObject:self.req_owneraddress forKey:@"owneraddress"];
    [params safetySetObject:self.req_location forKey:@"location"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_order = [HKInsuranceOrder orderWithJSONResponse:dict[@"order"]];
	
    return self;
}


- (NSString *)description
{
    return @"在线购买详情获取";
}
@end

