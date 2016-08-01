//
//  CalculateInsuranceCarPremiumOp.m
//  XiaoMa
//
//  Created by jt on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CalculateInsuranceCarPremiumOp.h"

@implementation CalculateInsuranceCarPremiumOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/insurance/car/premium/calculate";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params safetySetObject:self.carPremiumId forKey:@"carpremiumid"];
    [params safetySetObject:self.inslist forKey:@"inslist"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if([rspObj isKindOfClass:[NSDictionary class]])
    {
    }
    else
    {
        NSAssert(NO, @"rac_postRequest parse error~~");
    }
    return self;
}

- (NSString *)description
{
    return @"核保车辆";
}

@end
