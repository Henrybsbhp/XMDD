//
//  GetUserCarOp.m
//  XiaoMa
//
//  Created by jt on 15-4-17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserCarOp.h"
#import "HKMyCar.h"

@implementation GetUserCarOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/car/get";
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:nil security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    NSDictionary *dict = rspObj;

    self.rsp_tip = dict[@"tip"];
    
    NSArray * cars = dict[@"cars"];
    NSMutableArray * tArray = [NSMutableArray array];
    for (NSDictionary * dict in cars)
    {
        HKMyCar * car = [HKMyCar carWithJSONResponse:dict];
        [tArray addObject:car];
    }
    self.rsp_carArray = tArray;
    
    return self;
}


- (NSString *)description
{
    return @"获取用户爱车列表";
}
@end
