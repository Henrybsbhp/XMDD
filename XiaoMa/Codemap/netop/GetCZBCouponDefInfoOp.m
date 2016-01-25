#import "GetCZBCouponDefInfoOp.h"

@implementation GetCZBCouponDefInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/czbcoupon/defaultinfo/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_desc = dict[@"desc"];
    self.rsp_chargeupplimit = dict[@"chargeupplimit"];
	
    return self;
}

@end

