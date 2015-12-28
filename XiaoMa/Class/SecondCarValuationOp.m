//
//  SecondCarValuationOp.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "SecondCarValuationOp.h"

@implementation SecondCarValuationOp

-(RACSignal *)rac_postRequest
{
    self.req_method = @"/thirdpart/sellerchannel/get";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.req_sellerCityId forKey:@"sellercityid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

-(instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dataDic = (NSDictionary *)rspObj;
        self.rsp_dataArr = dataDic[@"channels"];
        self.rsp_tip = dataDic[@"tip"];
    }
    else
    {
        
        NSAssert(NO, @"SecondCarValuationOp parse error");
    }
    return self;
}

@end
