#import "AuthByVcodeOp.h"

@implementation AuthByVcodeOp

- (RACSignal *)RACSignal {
  self.req_method = @"/auth/by-vcode";
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
[params addParam:self.req_deviceid forName:"deviceid"];

  return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    
	return self;
}

@end

