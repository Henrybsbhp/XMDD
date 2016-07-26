#import "UpdateCalculatePremiumOp.h"

@implementation UpdateCalculatePremiumOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/premium/calculate/update";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];
    [params safetySetObject:self.req_mstartdate forKey:@"mstartdate"];
    [params safetySetObject:self.req_fstartdate forKey:@"fstartdate"];
    [params safetySetObject:self.req_brand forKey:@"brand"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

- (NSString *)description
{
    return @"车辆本地核保更新";
}

@end

