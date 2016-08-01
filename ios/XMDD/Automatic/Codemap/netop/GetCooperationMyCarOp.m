#import "GetCooperationMyCarOp.h"

@implementation GetCooperationMyCarOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/mycar/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_reports = rspObj[@"reports"];
    return self;
}

- (NSString *)description
{
    return @"获取车列表，在快速理赔的时候需要选择一辆车";
}
@end

