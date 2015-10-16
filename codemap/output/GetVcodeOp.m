#import "GetVcodeOp.h"

@implementation GetVcodeOp

- (RACSignal *)RACSignal {
  self.req_method = @"/vcode/get";
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
[params addParam:self.req_phone forName:"phone"];[params addParam:self.req_token forName:"token"];[params addParam:@(self.req_type) forName:"type"];

  return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    
	return self;
}

@end

