#import "UpdateDeliveryInfoOp.h"

@implementation UpdateDeliveryInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/premium/deliveryinfo/update";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_orderid forKey:@"orderid"];
    [params safetySetObject:self.req_contatorname forKey:@"contatorname"];
    [params safetySetObject:self.req_contatorphone forKey:@"contatorphone"];
    [params safetySetObject:self.req_address forKey:@"address"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_couponlist = dict[@"couponlist"];
	
    return self;
}

@end

