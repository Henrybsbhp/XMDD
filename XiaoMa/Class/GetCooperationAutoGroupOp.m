//
//  GetCooperationAutoGroup.m
//  XiaoMa
//
//  Created by jt on 16/3/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetCooperationAutoGroupOp.h"

@implementation GetCooperationAutoGroupOp


- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/autogroup/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.province forName:@"province"];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSArray * grouplist = rspObj[@"autogroups"];
    self.rsp_autoGroupArray = grouplist;
    return self;
}


@end
