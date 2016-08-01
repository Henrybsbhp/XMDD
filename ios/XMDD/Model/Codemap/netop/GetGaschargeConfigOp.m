#import "GetGaschargeConfigOp.h"

@implementation GetGaschargeConfigOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascharge/config/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_desc = dict[@"desc"];
    self.rsp_discountrate = [dict[@"discountrate"] intValue];
    self.rsp_couponupplimit = [dict[@"couponupplimit"] intValue];
    self.rsp_chargeupplimit = dict[@"chargeupplimit"];
    self.rsp_tip = dict[@"tip"];
    self.rsp_supportamt = dict[@"supportamt"];
    NSMutableArray *packages = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"packages"]) {
        GasChargePackage *obj = [GasChargePackage createWithJSONDict:curDict];
        [packages addObject:obj];
    }
    self.rsp_packages = packages;
    
    return self;
}

- (NSArray *)generateAllChargePackages
{
    NSMutableArray *pkgs = [NSMutableArray arrayWithArray:self.rsp_packages];
    
    GasChargePackage *normalPkg = [[GasChargePackage alloc] init];
    normalPkg.discount = [[NSString alloc] initWithInteger:(100 - self.rsp_discountrate)];
    normalPkg.month = 1;
    normalPkg.pkgid = @0;
    [pkgs safetyInsertObject:normalPkg atIndex:0];
    
    return pkgs;
}

- (NSString *)description
{
    return @"获取充值配置信息";
}
@end

