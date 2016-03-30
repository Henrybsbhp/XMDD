#import "CheckCooperationPremiumOp.h"

@implementation CheckCooperationPremiumOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/premium/check";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_licensenumbers = dict[@"licensenumbers"];
    self.rsp_inprocesslisnums = dict[@"inprocesslisnums"];
	
    return self;
}

@end

