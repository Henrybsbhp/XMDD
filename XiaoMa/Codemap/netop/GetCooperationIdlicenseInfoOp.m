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
	self.rsp_mininsenddate = [NSDate dateWithD10Text:dict[@"mininsenddate"]];
    return self;
}

- (NSString *)description
{
    return @"照片信息完善页面信息获取,照片信息完善前调用或者审核失败后重新提交图片时调用";
}

@end

