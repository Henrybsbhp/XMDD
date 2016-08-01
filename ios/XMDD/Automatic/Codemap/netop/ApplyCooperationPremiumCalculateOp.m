#import "ApplyCooperationPremiumCalculateOp.h"

@implementation ApplyCooperationPremiumCalculateOp

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

- (NSString *)description
{
    return @"团长报价申请";
}
@end

