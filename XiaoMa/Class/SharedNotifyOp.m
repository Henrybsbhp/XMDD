//
//  SharedNotifyOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/1.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "SharedNotifyOp.h"

@implementation SharedNotifyOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/redenvelope/shared/notify";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    if (self.req_channel) {
        [params addParam:self.req_channel forName:@"channel"];
    }
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_flag = [rspObj integerParamForName:@"getcouponflag"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

- (NSString *)description
{
    return @"红包分享后通知";
}
@end
