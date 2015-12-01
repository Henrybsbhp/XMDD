//
//  GetGeneralUnionpayTradenoOP.m
//  XiaoMa
//
//  Created by jt on 15/11/18.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetGeneralUnionpayTradenoOp.h"

@implementation GetGeneralUnionpayTradenoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/unionpay/tradeno/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.tradeNo forName:@"tradeno"];
    [params addParam:self.tradeType forName:@"tradetype"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_uniontradeno = [rspObj stringParamForName:@"uniontradeno"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
