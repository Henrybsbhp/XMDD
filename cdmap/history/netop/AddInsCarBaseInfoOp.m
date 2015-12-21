#import "AddInsCarBaseInfoOp.h"

@implementation AddInsCarBaseInfoOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/premium/add";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_name forKey:@"name"];
    [params safetySetObject:self.req_province forKey:@"province"];
    [params safetySetObject:self.req_city forKey:@"city"];
    [params safetySetObject:self.req_frameno forKey:@"frameno"];
    [params safetySetObject:self.req_brandname forKey:@"brandname"];
    [params safetySetObject:self.req_engineno forKey:@"engineno"];
    [params safetySetObject:@(self.req_transferflag) forKey:@"transferflag"];
    [params safetySetObject:self.req_transferdate forKey:@"transferdate"];
    [params safetySetObject:self.req_licensenum forKey:@"licensenum"];
    [params safetySetObject:self.req_regdate forKey:@"regdate"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_carpremiumid = dict[@"carpremiumid"];
    self.rsp_seatcount = dict[@"seatcount"];
	
    return self;
}

@end

