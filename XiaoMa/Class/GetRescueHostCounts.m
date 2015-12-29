//
//  GetRescueHostCounts.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueHostCounts.h"

@implementation GetRescueHostCounts
- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/get/hostCounts";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.licensenumber forName:@"licensenumber"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}
- (instancetype)parseResponseObject:(id)rspObj {
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.counts = rspObj[@"counts"];
        self.amount = rspObj[@"amount"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
    
    
}
@end
