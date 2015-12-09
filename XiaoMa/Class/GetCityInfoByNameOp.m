//
//  GetCityInfoByNameOp.m
//  XiaoMa
//
//  Created by jt on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetCityInfoByNameOp.h"

@implementation GetCityInfoByNameOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/province/getCityinfo/byName";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.province ? self.province : @"" forName:@"province"];
    [params addParam:self.city ? self.city : @"" forName:@"city"];
    [params addParam:self.district ? self.district : @"" forName:@"district"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.cityInfo = [ViolationCityInfo cityWithJSONResponse:rspObj[@"cityinfo"]];
        self.cityInfo.cityName = self.city;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
