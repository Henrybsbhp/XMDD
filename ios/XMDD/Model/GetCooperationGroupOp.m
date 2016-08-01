//
//  GetCooperationGroupOp.m
//  XiaoMa
//
//  Created by RockyYe on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetCooperationGroupOp.h"

@implementation GetCooperationGroupOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/group/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_status forName:@"status"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dic = rspObj;
    self.rsp_groupList = dic[@"grouplist"];
    self.rsp_isShowdetailflag = [dic boolParamForName:@"showdetailflag"];
    return self;
}

@end
