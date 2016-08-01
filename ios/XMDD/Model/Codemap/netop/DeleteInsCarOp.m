#import "DeleteInsCarOp.h"

@implementation DeleteInsCarOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/premium/car/del";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

- (NSString *)description
{
    return @"移除核保记录车辆";
}
@end

