#import "GetInsProvinceListOp.h"

@implementation GetInsProvinceListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/support/province/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *provinces = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"provinces"]) {
        Area *obj = [Area createWithJSONDict:curDict];
        [provinces addObject:obj];
    }
    self.rsp_provinces = provinces;
	
    return self;
}

@end

