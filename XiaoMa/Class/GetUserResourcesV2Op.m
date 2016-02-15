//
//  GetUserResourcesV2Op.m
//  XiaoMa
//
//  Created by jt on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GetUserResourcesV2Op.h"
#import "HKBankCard.h"

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
        NSMutableArray * tArray2 = [[NSMutableArray alloc] init];
        for (NSDictionary * dict in creditCards)
        {
            HKBankCard * card = [HKBankCard bankCardWithJSONResponse:dict];
            [tArray2 addObject:card];
        }
        self.rsp_coupons = tArray;
        self.rsp_czBankCreditCard = tArray2;
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




@end
