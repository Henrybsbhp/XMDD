#import "GetInsBaseCarListByIDOp.h"

@implementation GetInsBaseCarListByIDOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/carpremium/baseinfo/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_basecar = [InsBaseCar createWithJSONDict:dict];
	
    return self;
}

@end

