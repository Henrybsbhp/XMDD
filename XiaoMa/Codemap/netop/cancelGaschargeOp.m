#import "cancelGaschargeOp.h"

@implementation cancelGaschargeOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascharge/cancel";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_tradeid forKey:@"tradeid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

