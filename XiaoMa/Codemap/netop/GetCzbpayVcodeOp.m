#import "GetCzbpayVcodeOp.h"

@implementation GetCzbpayVcodeOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/czbpay/vcode/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_phone forKey:@"phone"];
    [params safetySetObject:self.req_cardid forKey:@"cardid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

