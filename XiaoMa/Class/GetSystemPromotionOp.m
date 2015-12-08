//
//  GetSystemPromotionOp.m
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetSystemPromotionOp.h"

@implementation GetSystemPromotionOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/system/promotion/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.type) forName:@"type"];
    [params addParam:self.province forName:@"province"];
    [params addParam:self.city forName:@"city"];
    [params addParam:self.district forName:@"district"];
    [params addParam:self.version forName:@"version"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * t = rspObj[@"promotions"];
        NSMutableArray * tarray = [NSMutableArray array];
        for (NSDictionary * dict in t)
        {
            HKAdvertisement * ad = [HKAdvertisement adWithJSONResponse:dict];
            [tarray addObject:ad];
        }
        self.rsp_advertisementArray = [NSArray arrayWithArray:tarray];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
