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
    NSMutableArray *carinfolist = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"carinfolist"]) {
        InsSimpleCar *obj = [InsSimpleCar createWithJSONDict:curDict];
        [carinfolist addObject:obj];
    }
    self.rsp_carinfolist = carinfolist;
    self.rsp_xmddhelptip = dict[@"xmddhelptip"];
	
    return self;
}

@end

