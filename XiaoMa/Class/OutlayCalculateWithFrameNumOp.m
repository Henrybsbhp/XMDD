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
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    self.brandName = rspObj[@"brandname"];
    self.carFrameNo = rspObj[@"frameno"];
    self.premiumPrice = rspObj[@"premiumprice"];
    self.serviceFee = rspObj[@"servicefee"];
    self.shareMoney = rspObj[@"sharemoney"];
    self.note = rspObj[@"note"];
    
    return self;
}

@end
