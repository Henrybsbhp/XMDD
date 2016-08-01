//
//  GetAreaInfoOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetAreaInfoOp.h"

@implementation GetAreaInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/province/getInfo/byUpdatetime";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addParam:@(self.req_updateTime) forName:@"updatetime"];
    [params addParam:@(self.req_type) forName:@"type"];
    [params addParam:@(self.req_areaId) forName:@"id"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray *areaArray = [NSMutableArray array];
        for (NSDictionary *areaDict in rspObj[@"areainfo"]) {
            HKAreaInfoModel *area = [HKAreaInfoModel areaWithJSONResponse:areaDict];
            [areaArray safetyAddObject:area];
        }
        self.rsp_areaArray = areaArray;
        self.rsp_maxTime = [rspObj[@"maxtime"] longLongValue];
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
    return @"获取省市区的id,名称，简称";
}
@end
