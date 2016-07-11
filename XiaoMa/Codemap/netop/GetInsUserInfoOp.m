#import "GetInsUserInfoOp.h"

@implementation GetInsUserInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/userinfo/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_orderid forKey:@"orderid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_name = dict[@"name"];
    self.rsp_phone = dict[@"phone"];
    self.rsp_location = dict[@"location"];
    self.rsp_address = dict[@"address"];
	
    return self;
}

- (NSString *)description
{
    return @"获取保险订单保险人的信息";
}
@end

