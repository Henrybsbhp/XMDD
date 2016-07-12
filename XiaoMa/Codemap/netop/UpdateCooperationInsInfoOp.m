#import "UpdateCooperationInsInfoOp.h"

@implementation UpdateCooperationInsInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/insurance/info/update";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];
    [params safetySetObject:self.req_proxybuy forKey:@"proxybuy"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

- (NSString *)description
{
    return @"保险信息更新到团中";
}
@end

