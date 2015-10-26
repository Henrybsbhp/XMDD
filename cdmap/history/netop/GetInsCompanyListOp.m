#import "GetInsCompanyListOp.h"

@implementation GetInsCompanyListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"system/inscomps/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_names = dict[@"names"];
	
    return self;
}

@end

