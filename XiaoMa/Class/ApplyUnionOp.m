//
//  ApplyUnionOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/26.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "ApplyUnionOp.h"

@implementation ApplyUnionOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/shop/union/apply";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_phone forName:@"phone"];
    [params addParam:self.req_name forName:@"name"];
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"district"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

@end
