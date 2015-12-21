//
//  GetAreaByIdOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "GetAreaByIdOp.h"
#import "Area.h"

@implementation GetAreaByIdOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/province/getInfo/byUpdatetime";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addParam:@(self.req_updateTime) forName:@"updatetime"];
    [params addParam:@(self.req_type) forName:@"type"];
    [params addParam:self.req_areaId forName:@"id"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSMutableArray *areaArray = [NSMutableArray array];
    for (NSDictionary *areaDict in dict[@"areainfo"]) {
        Area *area = [Area createWithJSONDict:areaDict];
        area.level = self.req_type;
        [areaArray safetyAddObject:area];
    }
    self.rsp_areaArray = areaArray;
    self.rsp_maxTime = [rspObj[@"maxtime"] longLongValue];

    return self;
}

@end
