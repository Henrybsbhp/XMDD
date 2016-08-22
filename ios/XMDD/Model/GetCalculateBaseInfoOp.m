//
//  GetCalculateBaseInfoOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "GetCalculateBaseInfoOp.h"

@implementation GetCalculateBaseInfoOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/premium/baseinfo/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.insuranceList = rspObj[@"insurancelist"];
    self.couponList = rspObj[@"couponlist"];
    self.activityList = rspObj[@"activitylist"];
    self.totalMemberCnt = [rspObj[@"totalmembercnt"] integerValue];;
    self.totalPoolAmt = rspObj[@"totalpoolamt"];
    self.totalClaimCnt = [rspObj[@"totalclaimcnt"] integerValue];
    self.totalClaimAmt = rspObj[@"totalclaimamt"];
    
    return self;
}

@end
