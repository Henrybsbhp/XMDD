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
    insModel.insList = rspObj[@"inslist"];
    insModel.minthirdSum = [rspObj stringParamForName:@"minthirdsum"];
    insModel.thirdsumTip = [rspObj stringParamForName:@"thirdsumtip"];
    insModel.minseatSum = [rspObj stringParamForName:@"minseatsum"];
    insModel.seatsumTip = [rspObj stringParamForName:@"seatsumtip"];
    insModel.purchasePrice = [rspObj floatParamForName:@"purchaseprice"];
    insModel.remindTip = [rspObj stringParamForName:@"remindtip"];
    insModel.xmddDiscount = [rspObj floatParamForName:@"xmdddiscount"];
    
    self.rsp_insModel = insModel;
    return self;
}

@end
