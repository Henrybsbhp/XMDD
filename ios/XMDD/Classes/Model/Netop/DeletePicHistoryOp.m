//
//  deletePicHistoryOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "DeletePicHistoryOp.h"

@implementation DeletePicHistoryOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/licensehis/delete";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_picID forName:@"lid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSString *)description
{
    return @"移除用户历史行驶证图片";
}
@end
