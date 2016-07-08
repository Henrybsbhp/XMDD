#import "GetGascardListOp.h"

@implementation GetGascardListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascard/list";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *gascards = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"gascards"]) {
        GasCard *obj = [GasCard createWithJSONDict:curDict];
        [gascards addObject:obj];
    }
    self.rsp_gascards = gascards;
	
    return self;
}
- (NSString *)description
{
    return @"获取油卡列表";
}

@end

