//
//  CalculateCooperationFreePremiumOp.m
//  XMDD
//
//  Created by RockyYe on 16/9/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CalculateCooperationFreePremiumOp.h"

@implementation CalculateCooperationFreePremiumOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/free/premium/calculate";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.req_frameno forName:@"frameno"];
    [params addParam:self.req_blackbox forName:@"blackbox"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:NO];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.model = [[PremiumModel alloc]init];
    self.model.brandName = rspObj[@"brandname"];
    self.model.carFrameNo = rspObj[@"frameno"];
    self.model.premiumPrice = rspObj[@"premiumprice"];
    self.model.serviceFee = rspObj[@"servicefee"];
    self.model.shareMoney = rspObj[@"sharemoney"];
    self.model.note = rspObj[@"note"];
    return self;
}

- (NSString *)description
{
    return @"根据车架号核算费用.不需要签名";
}

@end
