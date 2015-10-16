#import "GetTokenOp.h"

@implementation GetTokenOp

- (RACSignal *)RACSignal {
  self.req_method = @"/token/get";
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
[params addParam:self.req_phone forName:"phone"];

  return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_token = dict[@"token"];
    self.rsp_expires = [dict[@"expires"] intValue];
    
	return self;
}

@end

