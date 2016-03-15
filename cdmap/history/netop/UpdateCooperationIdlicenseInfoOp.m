#import "UpdateCooperationIdlicenseInfoOp.h"

@implementation UpdateCooperationIdlicenseInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/idlicense/info/update";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_idurl forKey:@"idurl"];
    [params safetySetObject:self.req_licenseurl forKey:@"licenseurl"];
    [params safetySetObject:self.req_firstinscomp forKey:@"firstinscomp"];
    [params safetySetObject:self.req_secinscomp forKey:@"secinscomp"];
    [params safetySetObject:self.req_memberid forKey:@"memberid"];
    [params safetySetObject:self.req_insenddate forKey:@"insenddate"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

