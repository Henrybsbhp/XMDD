//
//  getAreaByPcdOp.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/7.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "getAreaByPcdOp.h"

@implementation getAreaByPcdOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/province/getarea/bypcd";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params addParam:self.req_province forName:@"province"];
    [params addParam:self.req_city forName:@"city"];
    [params addParam:self.req_district forName:@"district"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_province = [rspObj stringParamForName:@"province"];
        self.rsp_city = [rspObj stringParamForName:@"city"];
        self.rsp_district = [rspObj stringParamForName:@"district"];
        self.rsp_refId = [rspObj integerParamForName:@"refid"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

@end
