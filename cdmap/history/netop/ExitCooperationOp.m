#import "ExitCooperationOp.h"

@implementation ExitCooperationOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/member/exit";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

