//
//  GetStartHostCarOp.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/18.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetStartHostCarOp.h"

@implementation GetStartHostCarOp
- (RACSignal *)rac_postRequest {
    self.req_method = @"/rescue/start/hostcar";
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
    
}
- (instancetype)parseResponseObject:(id)rspObj
{
    
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        
    }
    
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
    
}

@end
