#import "InsuranceAppointmentV2Op.h"

@implementation InsuranceAppointmentV2Op

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/appointment/v2";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_carpremiumid forKey:@"carpremiumid"];
    [params safetySetObject:self.req_idcard forKey:@"idcard"];
    [params safetySetObject:self.req_ownername forKey:@"ownername"];
    [params safetySetObject:self.req_startdate forKey:@"startdate"];
    [params safetySetObject:self.req_forcestartdate forKey:@"forcestartdate"];
    [params safetySetObject:self.req_inscomp forKey:@"inscomp"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

@end

