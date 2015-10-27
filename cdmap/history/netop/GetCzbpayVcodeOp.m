#import "GetCzbpayVcodeOp.h"

@implementation GetCzbpayVcodeOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/czbpay/vcode/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_cardid forKey:@"cardid"];
    [params safetySetObject:@(self.req_chargeamt) forKey:@"chargeamt"];
    [params safetySetObject:self.req_gid forKey:@"gid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_orderid = dict[@"orderid"];
    self.rsp_tradeid = dict[@"tradeid"];
	
    return self;
}

@end

