#import "UpdateCooperationIdlicenseInfoOp.h"

@implementation UpdateCooperationIdlicenseInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/idlicense/info/update";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_inslist forKey:@"inslist"];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];
    [params safetySetObject:self.req_proxybuy forKey:@"proxybuy"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

