#import "ApplyCooperationClaimOp.h"

@implementation ApplyCooperationClaimOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/cooperation/claim/apply";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_licensenumber forKey:@"licensenumber"];
    [params safetySetObject:self.req_scene forKey:@"scene"];
    [params safetySetObject:self.req_cardamage forKey:@"cardamage"];
    [params safetySetObject:self.req_carinfo forKey:@"carinfo"];
    [params safetySetObject:self.req_idinfo forKey:@"idinfo"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_total = [dict[@"total"] floatValue];
    self.rsp_tradeno = dict[@"tradeno"];
	
    return self;
}

@end

