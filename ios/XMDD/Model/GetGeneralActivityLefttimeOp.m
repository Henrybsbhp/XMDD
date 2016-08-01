//
//  GetGeneralActivityLefttimeOp.m
//  XiaoMa
//
//  Created by jt on 15/11/18.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetGeneralActivityLefttimeOp.h"

@implementation GetGeneralActivityLefttimeOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/activity/lefttime/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.tradeType forName:@"tradetype"];
    [params addParam:self.tradeNo forName:@"tradeno"];
    [params addParam:@(self.panchannel) forName:@"paychannel"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_lefttime = [rspObj integerParamForName:@"lefttime"];
        self.rsp_payInfoModel = [PayInfoModel payInfoWithJSONResponse:rspObj[@"payinfo"]];
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
    return @"查询活动剩余结束时间";
}

@end
