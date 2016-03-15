#import "GetCooperationIdlicenseInfoOp.h"

@implementation GetCooperationIdlicenseInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/idlicense/info/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_memberId forKey:@"memberid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_licenseurl = dict[@"licenseurl"];
    self.rsp_idnourl = dict[@"idnourl"];
    self.rsp_lstinscomp = dict[@"lstinscomp"];
    self.rsp_secinscomp = dict[@"secinscomp"];
    self.rsp_insenddate = [NSDate dateWithD10Text:dict[@"insenddate"]];
	
    return self;
}

@end

