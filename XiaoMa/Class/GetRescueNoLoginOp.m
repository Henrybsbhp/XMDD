//
//  GetRescueNoLoginOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueNoLoginOp.h"
#import "HKRescueNoLogin.h"
@implementation GetRescueNoLoginOp
- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/servicelist/nologin";
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * rescue = (NSArray *)rspObj[@"servicelist"];
        NSMutableArray * rArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in rescue)
        {
            if (dict != nil) {
                HKRescueNoLogin *rescue  = [[HKRescueNoLogin alloc] init];
                rescue.rescueID = dict[@"id"];
                rescue.rescueDesc = dict[@"description"];
                rescue.serviceName = dict[@"servicename"];
                rescue.amount = dict[@"amount"];
                rescue.type = [dict integerParamForName:@"type"];
                [rArray safetyAddObject:rescue];
                
            }
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
@end
