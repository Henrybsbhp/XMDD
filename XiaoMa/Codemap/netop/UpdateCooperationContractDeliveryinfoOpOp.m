#import "UpdateCooperationContractDeliveryinfoOpOp.h"

@implementation UpdateCooperationContractDeliveryinfoOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/contract/deliveryinfo/update";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_contractid forKey:@"contractid"];
    [params safetySetObject:self.req_contactname forKey:@"contactname"];
    [params safetySetObject:self.req_contactphone forKey:@"contactphone"];
    [params safetySetObject:self.req_address forKey:@"address"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

