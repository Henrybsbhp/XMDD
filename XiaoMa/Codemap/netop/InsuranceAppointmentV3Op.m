#import "InsuranceAppointmentV3Op.h"

@implementation InsuranceAppointmentV3Op

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/appointment/v3";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_licenseno forKey:@"licenseno"];
    [params safetySetObject:self.req_idcard forKey:@"idcard"];
    [params safetySetObject:self.req_driverpic forKey:@"driverpic"];
    [params safetySetObject:self.req_inslist forKey:@"inslist"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
        	
    return self;
}

- (NSString *)description
{
    return @"保险精准核保后预约购买";
}
@end

