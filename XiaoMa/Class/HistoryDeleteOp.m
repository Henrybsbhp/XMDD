//
//  HistoryDeleteOp.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/18.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "HistoryDeleteOp.h"

@implementation HistoryDeleteOp

-(RACSignal *)rac_postRequest
{
    self.req_method=@"/thirdpart/car/evaluate/his/del";
    NSMutableDictionary *params=[NSMutableDictionary new];
    [params safetySetObject:self.req_evaluateIds forKey:@"evaluateids"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    return self;
}

- (NSString *)description
{
    return @"车估值历史记录移除";
}

@end
