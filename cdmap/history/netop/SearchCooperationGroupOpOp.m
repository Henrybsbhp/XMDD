#import "SearchCooperationGroupOpOp.h"

@implementation SearchCooperationGroupOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/search";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_cipher forKey:@"cipher"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_name = dict[@"name"];
    self.rsp_creatorname = dict[@"creatorname"];
    self.rsp_groupid = dict[@"groupid"];
	
    return self;
}

@end

