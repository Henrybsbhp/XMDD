//
//  JTUser.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTUser.h"
#import "XiaoMa.h"
#import "GetUserCarOp.h"

@implementation JTUser

- (HKMyCar *)getDefaultCar
{
    for (HKMyCar * car in self.carArray)
    {
        if (car.isDefault)
        {
            return car;
        }
    }
    if (self.carArray.count)
    {
        return [self.carArray safetyObjectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

- (RACSignal *)rac_requestGetUserCar
{
    RACSignal * signal;
    GetUserCarOp * op = [GetUserCarOp operation];
    signal = [[[op rac_postRequest] flattenMap:^RACStream *(GetUserCarOp * op) {
        
        if (op.rsp_code == 0)
        {
            self.carArray = op.rsp_carArray;
            [self getDefaultCar];
            return [RACSignal return:op.rsp_carArray];
        }
        else
        {
            NSError * error = [NSError errorWithDomain:op.rsp_errorMsg code:op.rsp_code userInfo:nil];
            return [RACSignal error:error];
        }
    }]catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
    return signal;
}

@end

