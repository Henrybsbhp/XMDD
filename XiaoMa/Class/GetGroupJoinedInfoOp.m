//
//  GetGroupJoinedInfoOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetGroupJoinedInfoOp.h"

@implementation GetGroupJoinedInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/mygroup/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.carList = rspObj[@"carlist"];
    self.couponList = rspObj[@"couponlist"];
    self.showPlanBtn = rspObj[@"showplanbtn"];
    self.showRegistBtn = rspObj[@"showregistbtn"];
    
    return self;
}

@end
