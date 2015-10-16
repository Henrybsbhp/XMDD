#import "GetGaschargeRecordListOp.h"

@implementation GetGaschargeRecordListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/user/gascharge/his/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:@(self.req_payedtime) forKey:@"payedtime"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *gaschargeddatas = [NSMutableArray array];
    for (NSDictionary *curDict in dict[@"gaschargeddatas"]) {
        GasChargeRecord *obj = [GasChargeRecord createWithJSONDict:curDict];
        [gaschargeddatas addObject:obj];
    }
    self.rsp_gaschargeddatas = gaschargeddatas;
    self.rsp_charegetotal = [dict[@"charegetotal"] intValue];
    self.rsp_couponedtotal = [dict[@"couponedtotal"] intValue];
	
    return self;
}

@end

