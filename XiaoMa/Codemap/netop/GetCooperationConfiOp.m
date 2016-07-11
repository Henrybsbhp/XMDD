#import "GetCooperationConfiOp.h"

@implementation GetCooperationConfiOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/config/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_autogroupname = dict[@"autogroupname"];
    self.rsp_selfgroupname = dict[@"selfgroupname"];
    self.rsp_autogroupdesc = dict[@"autogroupdesc"];
    self.rsp_selfgroupdesc = dict[@"selfgroupdesc"];
	
    return self;
}

- (NSString *)description
{
    return @"获取互助首页面的文案配置信息";
}
@end

