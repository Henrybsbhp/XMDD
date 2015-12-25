
//
//  GetInsuranceOrderDetailsOp.m
//  XiaoMa
//  本代码由ckools工具自动生成,工具详情请联系作者@江俊辰
//  Created by Ckools
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetInsuranceOrderDetailsOp.h"

@implementation GetInsuranceOrderDetailsOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/order/insurance/detail/v2/get/by-id";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_orderid forName:@"orderid"];
    
      return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj[@"order"];
    self.rsp_order = [HKInsuranceOrder orderWithJSONResponse:dict];
    
    return self;
}

@end
