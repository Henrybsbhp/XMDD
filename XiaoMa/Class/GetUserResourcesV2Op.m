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
        //        NSMutableArray * tArray2 = [[NSMutableArray alloc] init];
        //        for (NSDictionary * dict in creditCards)
        //        {
        //            HKCoupon * coupon = [HKCoupon couponWithJSONResponse:dict];
        //            [tArray2 addObject:dict];
        //        }
        self.rsp_coupons = tArray;
        self.rsp_czBankCreditCard = creditCards;
        self.rsp_bankIntegral = [rspObj integerParamForName:@"bankcredits"];
        self.rsp_freewashes = [rspObj integerParamForName:@"freewashes"];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
