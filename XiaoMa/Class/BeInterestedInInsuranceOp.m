//
//  BeInterestedInInsuranceOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/27.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BeInterestedInInsuranceOp.h"

@implementation BeInterestedInInsuranceOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/calculate/add";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

@end
