//
//  GetCooperationClaimsListV2Op.m
//  XMDD
//
//  Created by RockyYe on 2016/10/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetCooperationClaimsListV2Op.h"

@implementation GetCooperationClaimsListV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/claims/v2/list";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.req_gid)
    {
        [params addParam:self.req_gid forName:@"gid"];
    }
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

-(instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_claimlist = rspObj[@"claimlist"];
    return self;
}


- (NSString *)description
{
    return @"理赔记录列表V2(理赔详情采用K-V模式)";
}

@end
