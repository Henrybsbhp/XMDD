//
//  UpdateInsuranceCalculateOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UpdateInsuranceCalculateOp.h"

@implementation UpdateInsuranceCalculateOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/calculate/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_cid forName:@"cid"];
    [params addParam:self.req_idpic forName:@"idpic"];
    [params addParam:self.req_driverpic forName:@"driverpic"];
    [params addParam:self.req_drivercopypic forName:@"drivercopypic"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
