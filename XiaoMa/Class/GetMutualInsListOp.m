//
//  GetMutualInsListOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetMutualInsListOp.h"

@implementation GetMutualInsListOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/ins/list/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_version forName:@"version"];
    [params addParam:self.req_memberId forName:@"memberid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    HKMutualInsList * insModel = [[HKMutualInsList alloc] init];
    
    insModel.premiumprice = [rspObj floatParamForName:@"premiumprice"];
    insModel.couponMoney = [rspObj floatParamForName:@"couponmoney"];
    insModel.couponList = rspObj[@"couponlist"];
    insModel.remindTip = [rspObj stringParamForName:@"remindtip"];
    insModel.memberFee = [rspObj floatParamForName:@"memberfee"];
    insModel.noteList = rspObj[@"notelist"];
    
    self.rsp_insModel = insModel;
    
    return self;
}

@end
