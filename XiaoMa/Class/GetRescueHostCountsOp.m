//
//  GetRescueHostCountsOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetRescueHostCountsOp.h"

@implementation GetRescueHostCountsOp
- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/get/hostCounts";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
   
    [params addParam:self.licenseNumber forName:@"licensenumber"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
    
}
- (instancetype)parseResponseObject:(id)rspObj
{
    
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.counts = rspObj[@"counts"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
    
}

@end
