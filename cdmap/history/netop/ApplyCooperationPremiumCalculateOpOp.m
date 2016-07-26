#import "ApplyCooperationPremiumCalculateOpOp.h"

@implementation ApplyCooperationPremiumCalculateOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/premium/calculate/apply";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

