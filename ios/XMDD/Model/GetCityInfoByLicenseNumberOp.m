//
//  GetCityInfoByLicenseNumberOp.m
//  XMDD
//
//  Created by fuqi on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetCityInfoByLicenseNumberOp.h"

@implementation GetCityInfoByLicenseNumberOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/cityinfo/get/by-licensenumber";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_lisenceNumber forName:@"licencenumber"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * cityInfoDict = rspObj[@"cityinfo"];
        ViolationCityInfo * cityInfo = [ViolationCityInfo cityWithJSONResponse:cityInfoDict];
        self.rsp_violationCityInfo = cityInfo;
        
        self.rsp_carframenumber = rspObj[@"carframenumber"];
        self.rsp_enginenumber = rspObj[@"enginenumber"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}



- (NSString *)description
{
    return @"获取用户车辆违章记录";
}


@end
