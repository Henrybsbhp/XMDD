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
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}

- (id)returnSimulateResponse
{
    return @{@"coupons":@[
                     @{@"amount":@5.0,@"cid":@28133,@"description":@"浙商洗车券",@"isShare":@0,@"name":@"5元洗车券",@"type":@7,@"used":@2,@"userId":@88,@"usercouponid":@0,@"valid":@1,@"valid_endtime":@0,@"valid_starttime":@0,@"validsince":@"20150731",@"validthrough":@"20150806"},
                     @{@"amount":@90.0,@"cid":@28133,@"description":@"代金券",@"isShare":@0,@"name":@"90元代金券",@"type":@2,@"used":@2,@"userId":@88,@"usercouponid":@0,@"valid":@1,@"valid_endtime":@0,@"valid_starttime":@0,@"validsince":@"20150731",@"validthrough":@"20150806"},
                     @{@"amount":@0.01,@"cid":@28252,@"description":@"仅限7座及以下非运营轿车",@"isShare":@0,@"name":@"1分洗车劵",@"type":@1,@"used":@2,@"userId":@88,@"usercouponid":@0,@"valid":@1,@"valid_endtime":@0,@"valid_starttime":@0,@"validsince":@"20150731",@"validthrough":@"20150806"},
                     @{@"amount":@0.01,@"cid":@28256,@"description":@"仅限7座及以下非运营轿车",@"isShare":@0,@"name":@"1分洗车劵",@"type":@1,@"used":@2,@"userId":@88,@"usercouponid":@0,@"valid":@1,@"valid_endtime":@0,@"valid_starttime":@0,@"validsince":@"20150731",@"validthrough":@"20150806"}],
             @"bindcards":@[@{@"cardid":@"6222021202017169716"}],
             @"bankcredits":@0,@"freewashes":@0,@"rc":@0,@"id":@13,@"newmsg":@0};
    //    return @{@"coupons":@[
    //
    //                     @{@"amount":@90.0,@"cid":@28133,@"description":@"代金券",@"isShare":@0,@"name":@"90元代金券",@"type":@2,@"used":@2,@"userId":@88,@"usercouponid":@0,@"valid":@1,@"valid_endtime":@0,@"valid_starttime":@0,@"validsince":@"20150731",@"validthrough":@"20150806"},
    //                     @{@"amount":@0.01,@"cid":@28252,@"description":@"仅限7座及以下非运营轿车",@"isShare":@0,@"name":@"1分洗车劵",@"type":@1,@"used":@2,@"userId":@88,@"usercouponid":@0,@"valid":@1,@"valid_endtime":@0,@"valid_starttime":@0,@"validsince":@"20150731",@"validthrough":@"20150806"},
    //                     @{@"amount":@0.01,@"cid":@28256,@"description":@"仅限7座及以下非运营轿车",@"isShare":@0,@"name":@"1分洗车劵",@"type":@1,@"used":@2,@"userId":@88,@"usercouponid":@0,@"valid":@1,@"valid_endtime":@0,@"valid_starttime":@0,@"validsince":@"20150731",@"validthrough":@"20150806"}],
    //             @"creditcards":@[],
    //             @"bankcredits":@0,@"freewashes":@0,@"rc":@0,@"id":@13,@"newmsg":@0};
}


@end
