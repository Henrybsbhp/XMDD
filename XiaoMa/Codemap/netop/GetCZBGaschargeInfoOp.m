#import "GetCZBGaschargeInfoOp.h"

@implementation GetCZBGaschargeInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/czbcard/couponinfo/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_gid forKey:@"gid"];
    [params safetySetObject:self.req_cardid forKey:@"cardid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_availablechargeamt = [dict[@"availablechargeamt"] intValue];
    self.rsp_couponedmoney = [dict[@"couponedmoney"] intValue];
    self.rsp_discountrate = [dict[@"discountrate"] intValue];
    self.rsp_couponupplimit = [dict[@"couponupplimit"] intValue];
    self.rsp_czbcouponedmoney = [dict[@"czbcouponedmoney"] intValue];
    self.rsp_chargeupplimit = [dict[@"chargeupplimit"] intValue];
	
    return self;
}

@end

