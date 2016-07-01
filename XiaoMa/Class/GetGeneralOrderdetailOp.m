//
//  GetGeneralOrderdetailOp.m
//  XiaoMa
//
//  Created by jt on 15/11/16.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "GetGeneralOrderdetailOp.h"
#import "HKBankCard.h"

@implementation GetGeneralOrderdetailOp

- (RACSignal *)rac_postRequest
{
    self.req_method = @"/general/orderdetail/get";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addParam:self.tradeNo forName:@"tradeno"];
    [params addParam:self.tradeType forName:@"tradetype"];
    
    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:YES];
}

- (instancetype)parseResponseObject:(id)rspObj
{
    if ([rspObj isKindOfClass:[NSDictionary class]])
    {
        self.rsp_prodlogo = [rspObj stringParamForName:@"prodlogo"];
        self.rsp_prodname = [rspObj stringParamForName:@"prodname"];
        self.rsp_proddesc = [rspObj stringParamForName:@"proddesc"];
        self.rsp_originprice = [rspObj floatParamForName:@"originprice"];
        self.rsp_couponprice = [rspObj floatParamForName:@"couponprice"];
        self.rsp_fee = [rspObj floatParamForName:@"fee"];
        self.rsp_paychannels = rspObj[@"paychannels"];
        NSArray * czbbanksArray = rspObj[@"czbcards"];
        NSMutableArray * tArray = [NSMutableArray array];
        for (NSDictionary * dict in czbbanksArray)
        {
            HKBankCard * card = [[HKBankCard alloc] init];
            card.cardID = [dict numberParamForName:@"cid"];
            card.cardNumber = [dict stringParamForName:@"cardno"];
            card.cardType = HKBankCardTypeCredit;
            card.bankType = HKBankTypeCZB;
        }
        self.rsp_czbCards = [NSArray arrayWithArray:tArray];
    }
    else
    {
        NSString * errorInfo = [NSString stringWithFormat:@"%@ parse error~~",NSStringFromClass([self class])];
        NSAssert(NO,errorInfo);
    }
    return self;
}


@end
