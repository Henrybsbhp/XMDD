//
//  GetRescueOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueOp.h"
#import "LoginViewModel.h"
@implementation GetRescueOp
- (RACSignal *)rac_postRequest {
        self.req_method = @"/rescue/servicelist/get";
        return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
   }


- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * rescue = (NSArray *)rspObj[@"servicelist"];
        NSMutableArray * rArray = [[NSMutableArray alloc] init];
        
        for (NSDictionary * dict in rescue)
        {
            HKRescue *rescue  = [[HKRescue alloc] init];
            
            rescue.serviceName = dict[@"servicename"];
            rescue.rescueDesc = dict[@"description"];
            rescue.rescueID = dict[@"id"];
            rescue.amount = dict[@"amount"];
            rescue.serviceCount = dict[@"servicecount"];
            rescue.type = [dict integerParamForName:@"type"];
            [rArray safetyAddObject:rescue];
        }
        
        self.rsp_resceuArray = rArray;
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

- (NSError *)mapError:(NSError *)error
{
    /// 把抢登的处理移除掉
    if (error.code == -2003)
    {
        error = [NSError errorWithDomain:error.domain code:9999 userInfo:error.userInfo];
    }
    return error;
}


- (NSString *)description
{
    return @"救援首页，获取救援列表";
}
@end
