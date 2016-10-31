//
//  UserViolationQueryOp.m
//  XiaoMa
//
//  Created by jt on 15/11/30.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "UserViolationQueryOp.h"
#import "HKViolation.h"

@implementation UserViolationQueryOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/violation/query";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.licencenumber forName:@"licencenumber"];
    if (self.engineno)
        [params addParam:self.engineno forName:@"engineno"];
    if (self.classno)
        [params addParam:self.classno forName:@"classno"];
    [params addParam:self.cid forName:@"cid"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_reason = rspObj[@"reason"];
        self.rsp_violationCount = [rspObj integerParamForName:@"count"];
        self.rsp_violationTotalfen = [rspObj integerParamForName:@"totalfen"];
        self.rsp_violationTotalmoney = [rspObj integerParamForName:@"totalmoney"];
        self.rsp_violationAvailableTip = [rspObj stringParamForName:@"tip"];
        NSMutableArray * tArray = [NSMutableArray array];
        for (NSDictionary * dict in rspObj[@"lists"])
        {
            HKViolation * violation = [HKViolation violationWithJSONResponse:dict];
            [tArray safetyAddObject:violation];
        }
        self.rsp_violationArray = [NSArray arrayWithArray:tArray];
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
    return @"获取用户车辆违章记录";
}
@end
