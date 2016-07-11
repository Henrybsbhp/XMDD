#import "GetPremiumDetailOp.h"

@implementation GetPremiumDetailOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/premium/detail/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];
    [params safetySetObject:self.req_inscomp forKey:@"inscomp"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *inslist = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"inslist"]) {
        InsCoveragePrice *obj = [InsCoveragePrice createWithJSONDict:curDict];
        [inslist addObject:obj];
    }
    self.rsp_inslist = inslist;
    self.rsp_setcount = [dict[@"setcount"] intValue];
    self.rsp_originprice = [dict[@"originprice"] doubleValue];
    self.rsp_price = [dict[@"price"] doubleValue];
    self.rsp_startdate = dict[@"startdate"];
    self.rsp_fstartdate = dict[@"fstartdate"];
    self.rsp_ownername = dict[@"ownername"];
    self.rsp_license = dict[@"license"];
    self.rsp_licenseurl = dict[@"licenseurl"];
    self.rsp_location = dict[@"location"];
    self.rsp_inslogo = dict[@"inslogo"];
    self.rsp_inscompname = dict[@"inscompname"];
    self.rsp_tip = dict[@"tip"];
	
    return self;
}


- (NSString *)description
{
    return @"在线购买详情获取";
}
@end

