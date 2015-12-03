//
//  GetShareButtonOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/11/26.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetShareButtonOp.h"

@implementation GetShareButtonOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/share/button/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.pagePosition) forName:@"position"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
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
