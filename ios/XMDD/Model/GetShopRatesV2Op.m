//
//  GetShopRatesV2Op.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetShopRatesV2Op.h"

@implementation GetShopRatesV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/shop/rates/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_shopid forName:@"shopid"];
    [params addParam:@(self.req_pageno) forName:@"pageno"];
    [params addParam:self.req_serviceTypes forName:@"servicetypes"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    _rsp_carwashTotalNumber = [dict integerParamForName:@"totalnumber"];
    _rsp_maintenanceTotalNumber = [dict integerParamForName:@"bytotalnumber"];
    _rsp_beautyTotalNumber = [dict integerParamForName:@"mrtotalnumber"];
    _rsp_carwashCommentArray = [self commentsWithDicts:dict[@"rates"]];
    _rsp_maintenanceCommentArray = [self commentsWithDicts:dict[@"byrates"]];
    _rsp_beautyCommentArray = [self commentsWithDicts:dict[@"mrrates"]];
    return self;
}

- (NSArray *)commentsWithDicts:(NSArray *)dicts {
    return [dicts arrayByMapFilteringOperator:^id(id obj) {
        return [JTShopComment shopCommentWithJSONResponse:obj];
    }];
}

- (NSString *)description
{
    return @"获取商户评价列表V2";
}

@end
