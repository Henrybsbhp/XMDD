//
//  GetCarwashOrderV2Op.m
//  XiaoMa
//
//  Created by jt on 15/11/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetCarwashOrderV2Op.h"

@implementation GetCarwashOrderV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/order/service/detail/v2/get/by-id";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_orderid forName:@"orderid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;
    NSArray * array = dict[@"orders"];
    self.rsp_order = [HKServiceOrder orderWithJSONResponse:[array safetyObjectAtIndex:0]];
    return self;
}


- (NSString *)description
{
    return @"获取用户的某一服务订单详情";
}
@end
