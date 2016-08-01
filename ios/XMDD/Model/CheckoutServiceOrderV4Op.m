//
//  CheckoutServiceOrderV4Op.m
//  XiaoMa
//
//  Created by jt on 15/11/9.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CheckoutServiceOrderV4Op.h"

@implementation CheckoutServiceOrderV4Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/order/service/v4/checkout";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString * cid;
    if (self.couponArray.count)
    {
        cid = [self.couponArray componentsJoinedByString:@","];
    }
    [params addParam:self.serviceid forName:@"serviceid"];
    [params addParam:self.licencenumber forName:@"licencenumber"];
    [params addParam:cid ? cid : @"" forName:@"cid"];
    [params addParam:@(self.paychannel) forName:@"paychannel"];
    [params addParam:self.carMake forName:@"make"];
    [params addParam:self.carModel forName:@"model"];
    [params addParam:[NSString stringWithFormat:@"%f", self.coordinate.longitude] forName:@"longitude"];
    [params addParam:[NSString stringWithFormat:@"%f", self.coordinate.latitude] forName:@"latitude"];
    [params addParam:self.bankCardId ? self.bankCardId : @0 forName:@"cardid"];
    [params addParam:self.blackbox forName:@"blackbox"];
    [params addParam:@(IOSAPPID) forName:@"os"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_tradeId = rspObj[@"tradeid"];
        self.rsp_price = [rspObj floatParamForName:@"total"];
        self.rsp_orderid = rspObj[@"orderid"];
        self.rsp_gasCouponAmount = [rspObj floatParamForName:@"gascouponamt"];
        self.rsp_notifyUrlStr = rspObj[@"notifyurl"];
        self.rsp_payInfoModel = [PayInfoModel payInfoWithJSONResponse:rspObj[@"payinfo"]];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

- (NSString *)description
{
    return @"支付服务类订单";
}

@end
