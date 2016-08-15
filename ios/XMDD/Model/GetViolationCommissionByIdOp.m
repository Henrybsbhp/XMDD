//
//  GetViolationCommissionByIdOp.m
//  XMDD
//
//  Created by RockyYe on 16/8/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetViolationCommissionByIdOp.h"

@implementation GetViolationCommissionByIdOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/commission/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_recordid forName:@"recordid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_data = @{@"licencenumber" : rspObj[@"licencenumber"],
                      @"date" : rspObj[@"date"],
                      @"area" : rspObj[@"area"],
                      @"act" : rspObj[@"act"],
                      @"money" : rspObj[@"money"],
                      @"servicefee" : rspObj[@"servicefee"],
                      @"status" : rspObj[@"status"]};
    return self;
}



- (NSString *)description
{
    return @"根据记录id获取代办记录信息";
}

@end
