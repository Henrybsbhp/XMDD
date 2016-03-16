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
    //根绝接口状态调整接口参数
    BOOL ifNeedSecurity = gAppMgr.myUser;
    
    self.req_method = ifNeedSecurity ? @"/cooperation/autogroup/get" : @"/cooperation/autogroup/nologin/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.province forName:@"province"];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:ifNeedSecurity];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSArray * grouplist = rspObj[@"autogroups"];
    self.rsp_autoGroupArray = grouplist;
    return self;
}


@end
