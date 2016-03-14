#import "GetCooperationIdlicenseInfoOpOp.h"

@implementation GetCooperationIdlicenseInfoOpOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/idlicense/info/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_groupid forKey:@"groupid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_licenseurl = dict[@"licenseurl"];
    self.rsp_idnourl = dict[@"idnourl"];
    self.rsp_lstinscomp = dict[@"lstinscomp"];
    self.rsp_insenddate = dict[@"insenddate"];
	
    return self;
}

@end

