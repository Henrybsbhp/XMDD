//
//  AddUserCarOp.m
//  XiaoMa
//
//  Created by jt on 15-4-30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AddUserCarOp.h"
#import "NSDate+DateForText.h"

@implementation AddUserCarOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/car/add";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.car.licencenumber forName:@"name"];
    [params addParam:[self.car.purchasedate dateFormatForDT8] forName:@"pageno"];
    [params addParam:self.car.brand forName:@"name"];
    [params addParam:self.car.model forName:@"name"];
    [params addParam:@(self.car.price) forName:@"name"];
    [params addParam:@(self.car.odo) forName:@"name"];
    [params addParam:self.car.inscomp forName:@"name"];
    [params addParam:[self.car.insexipiredate dateFormatForDT8] forName:@"pageno"];
    [params addParam:@(self.car.isDefault) forName:@"isdefault"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}


- (instancetype)parseResponseObject:(id)rspObj
{
    return self;
}

@end
