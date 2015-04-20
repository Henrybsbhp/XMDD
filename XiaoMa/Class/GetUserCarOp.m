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
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * cars = (NSArray *)rspObj[@"car"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in cars)
        {
            NSDictionary * detailDict = dict[@"cardetail"];
            HKMyCar * car = [HKMyCar carWithJSONResponse:detailDict];
            car.carId = dict[@"carid"];
            [tArray addObject:car];
        }
        self.rsp_carArray = [NSArray arrayWithArray:tArray];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
