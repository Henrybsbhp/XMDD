#import "AddCooperationGroupJoinOp.h"

@implementation AddCooperationGroupJoinOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/group/join/add";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_name forKey:@"name"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_cipher = dict[@"cipher"];
    self.rsp_groupid = dict[@"groupid"];
	
    return self;
}

@end

