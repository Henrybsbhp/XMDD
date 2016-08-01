#import "GetInsBaseCarListOp.h"

@implementation GetInsBaseCarListOp

- (RACSignal *)rac_postRequest {
    self.req_method = @"/insurance/car/detailinfo/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_name forKey:@"name"];
    [params safetySetObject:self.req_licensenum forKey:@"licensenum"];
    [params safetySetObject:self.req_carid forKey:@"carid"];

    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    self.rsp_basecar = [InsBaseCar createWithJSONDict:dict];
	
    return self;
}

@end

