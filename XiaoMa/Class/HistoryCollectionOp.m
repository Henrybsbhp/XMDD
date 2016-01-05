//
//  HistoryCollectionOp.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "HistoryCollectionOp.h"

@implementation HistoryCollectionOp

-(RACSignal *)rac_postRequest
{
    self.req_method=@"/thirdpart/car/evaluate/his/get";
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params safetySetObject:self.req_evaluateTime forKey:@"evaluatetime"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

-(instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *dataDic = (NSDictionary *)rspObj;
        self.rsp_dataArr = dataDic[@"evaluatelist"];
    }
    else
    {
        
        NSAssert(NO, @"HistoryCollectionOp parse error");
    }
    return self;
}

@end
