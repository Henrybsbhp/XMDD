#import "GetCooperationMyCarOp.h"

@implementation GetCooperationMyCarOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/mycar/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_licensenumbers = dict[@"licensenumbers"];
	
    return self;
}

@end

