//
//  GetUserResourcesV2Op.m
//  XiaoMa
//
//  Created by jt on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserResourcesV2Op.h"

@implementation GetUserResourcesV2Op

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/user/resources/v2/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:@(self.shopServiceType) forName:@"servicetype"];
    [params addParam:self.shopID forName:@"shopid"];
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        NSArray * coupons = (NSArray *)rspObj[@"coupons"];
        NSMutableArray * tArray = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in coupons)
        {
            HKCoupon * coupon = [HKCoupon couponWithJSONResponse:dict];
            [tArray addObject:coupon];
        }
        NSArray * creditCards = (NSArray *)rspObj[@"bindcards"];
        self.rsp_coupons = tArray;
        self.rsp_czBankCreditCard = creditCards;
        self.rsp_bankIntegral = [rspObj integerParamForName:@"bankcredits"];
        self.rsp_freewashes = [rspObj integerParamForName:@"freewashes"];
        
        self.rsp_neverCarwashFlag = [rspObj boolParamForName:@"neverwashcarflag"];
        self.rsp_carwashFlag = [rspObj boolParamForName:@"washcarflag"];
        self.rsp_activityDayFlag = [rspObj boolParamForName:@"activitydayflag"];
        self.rsp_weeklyCouponGetFlag = [rspObj boolParamForName:@"weeklycouponget"];
        self.rsp_maxGasCouponAmt = [rspObj intParamForName:@"maxgascouponamt"];
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
    return @"获取当前用户所有的银行洗车次数、积分和有效优惠券信息(包括浙商优惠券)";
}


@end
