//
//  DeleteCarOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DeleteCarOp.h"

@implementation DeleteCarOp
- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/car/delete";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_carid forName:@"carid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSString *)description
{
    return @"删除爱车";
}
@end
