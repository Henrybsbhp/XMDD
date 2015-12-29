//
//  GetRescueCommentOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/14.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueCommentOp.h"

@implementation GetRescueCommentOp
- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/get/commentdetail";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.applyId forName:@"applyid"];
    [params addParam:self.type forName:@"type"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
    
}
- (instancetype)parseResponseObject:(id)rspObj {
    
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        
        self.rescueDetailArray = [@[] mutableCopy];
        NSDictionary *dic = rspObj[@"rescuecomment"];
        if (dic != nil) {
            [self.rescueDetailArray safetyAddObject:dic[@"responsespeed"]];
            [self.rescueDetailArray safetyAddObject:dic[@"arrivespeed"]];
            [self.rescueDetailArray safetyAddObject:dic[@"serviceattitude"]];
            [self.rescueDetailArray safetyAddObject:dic[@"comment"]];
        }
    }
    else
    {
        
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
    
}
@end
