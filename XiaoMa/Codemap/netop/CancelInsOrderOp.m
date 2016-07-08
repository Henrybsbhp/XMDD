#import "CancelInsOrderOp.h"

@implementation CancelInsOrderOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/order/cancel";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_insorderid forKey:@"insorderid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

- (NSString *)description
{
    return @"取消保险订单";
}
@end

