//
//  SecondCarValuationUploadOp.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "SecondCarValuationUploadOp.h"

@implementation SecondCarValuationUploadOp

-(RACSignal *)rac_postRequest
{
    self.req_method = @"/thirdpart/sellwill/add";
    NSMutableDictionary *params=[NSMutableDictionary new];
    [params safetySetObject:self.req_carId forKey:@"carid"];
    [params safetySetObject:self.req_contatName forKey:@"contatname"];
    [params safetySetObject:self.req_contatPhone forKey:@"contatphone"];
    [params safetySetObject:self.req_channelEngs forKey:@"channelengs"];
    [params safetySetObject:self.req_sellercityid forKey:@"sellercityid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

-(instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *temp=(NSDictionary *)rspObj;
        self.rsp_rc = temp[@"rc"];
        self.rsp_tip = temp[@"tip"];
    }
    else
    {
        NSAssert(NO, @"SecondCarValuationUploadOp parse error");
    }
    return self;
}

@end
