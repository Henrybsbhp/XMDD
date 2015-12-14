//
//  getAreaByPcdOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetAreaByPcdOp.h"

@implementation GetAreaByPcdOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/province/getarea/bypcd";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_province = [HKAreaInfoModel areaWithJSONResponse:rspObj[@"province"]];
        self.rsp_city = [HKAreaInfoModel areaWithJSONResponse:rspObj[@"city"]];
        self.rsp_district = [HKAreaInfoModel areaWithJSONResponse:rspObj[@"district"]];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
