#import "DeleteGascardOp.h"

@implementation DeleteGascardOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascard/del";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:@(self.req_gid) forKey:@"gid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

