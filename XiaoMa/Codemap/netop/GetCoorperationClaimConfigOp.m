#import "GetCoorperationClaimConfigOp.h"

@implementation GetCoorperationClaimConfigOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/claim/config/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_scenedesc = dict[@"scenedesc"];
    self.rsp_cardamagedesc = dict[@"cardamagedesc"];
    self.rsp_carinfodesc = dict[@"carinfodesc"];
    self.rsp_idinfodesc = dict[@"idinfodesc"];
	
    return self;
}

- (NSString *)description
{
    return @"获取互助理赔页面的配置信息";
}
@end

