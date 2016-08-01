//
//  GetRescueCommentRescueOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueCommentRescueOp.h"

@implementation GetRescueCommentRescueOp
- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/commentrescue";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.applyId forName:@"applyid"];
    [params addParam:self.responseSpeed forName:@"responsespeed"];
    [params addParam:self.arriveSpeed forName:@"arrivespeed"];
    [params addParam:self.serviceAttitude forName:@"serviceattitude"];
    [params addParam:self.comment forName:@"comment"];
    [params addParam:self.rescueType forName:@"rescuetype"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (NSError *)mapError:(NSError *)error
{
    if (error.code == -1) {
        error = [NSError errorWithDomain:@"评论失败,请重试!" code:error.code userInfo:error.userInfo];
    }
    return error;
}


- (NSString *)description
{
    return @"对救援的服务进行评价";
}
@end
