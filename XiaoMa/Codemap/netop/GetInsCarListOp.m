#import "GetInsCarListOp.h"

@implementation GetInsCarListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/related/cars/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_carinfolist = dict[@"carinfolist"];
	
    return self;
}

@end

