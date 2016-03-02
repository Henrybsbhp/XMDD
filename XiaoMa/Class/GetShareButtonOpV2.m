//
//  GetShareButtonOpV2.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/2.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GetShareButtonOpV2.h"

@implementation GetShareButtonOpV2

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/share/button/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.pagePosition) forName:@"position"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_shareBtns = rspObj[@"buttons"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
