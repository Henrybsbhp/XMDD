//
//  SubmitCommentOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "SubmitCommentOp.h"
#import "XiaoMa.h"

@implementation SubmitCommentOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/order/service/rate";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_orderid forName:@"orderid"];
    [params addParam:@(self.req_rating) forName:@"rating"];
    [params addParam:self.req_comment forName:@"comment"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
