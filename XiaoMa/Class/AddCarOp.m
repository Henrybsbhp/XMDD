//
//  AddCarInfoOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AddCarOp.h"

@implementation AddCarOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/car/add";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self.req_car jsonDictForCarInfo]];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.rsp_carId = rspObj[@"carid"];
    return self;
}

- (NSString *)description
{
    return @"添加爱车接口";
}
@end
