//
//  OutlayCalculateWithFrameNumOp.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "OutlayCalculateWithFrameNumOp.h"

@implementation OutlayCalculateWithFrameNumOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/cooperation/premium/calculate";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.frameNo forName:@"frameno"];
    [params addParam:self.carID forName:@"carid"];
    [params addParam:self.blackBox forName:@"blackbox"];
    [params addParam:self.req_hasriskrecord forName:@"hasriskrecord"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
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
    
    self.rspDict = rspObj;
    
    return self;
}

-(NSString *)description
{
    return @"根据车架号核算费用.需要签名";
}

@end
