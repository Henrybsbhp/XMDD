//
//  UpdateCarInfoOp.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UpdateCarOp.h"

@implementation UpdateCarOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/car/update";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:[self.req_car jsonDictForCarInfo]];
    [params addParam:self.req_car.carId forName:@"carid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

@end
