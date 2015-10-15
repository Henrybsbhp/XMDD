//
//  GasCardStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasCardStore.h"
#import "GetGascardListOp.h"
#import "GetGaschargeInfoOp.h"
#import "GetCZBGaschargeInfoOp.h"

@implementation GasCardStore

- (CKStoreEvent *)getAllCardBaseInfos
{
    GetGascardListOp *op = [GetGascardListOp operation];
    RACSignal *sig = [[op rac_postRequest] map:^id(GetGascardListOp *rsp) {
        for (GasCard *card in rsp.rsp_gascards) {
            GasCard *oldCard = [self.cache objectForKey:card.gid];
            if (oldCard) {
                [oldCard mergeSimpleGasCard:card];
            }
            else {
                [self.cache addObject:card forKey:card.gid];
            }
        }
        return rsp.rsp_gascards;
    }];
    return [CKStoreEvent eventWithSignal:sig code:kGasGetAllCardBaseInfos object:nil];
}

- (CKStoreEvent *)getCardNormalInfoByGID:(NSNumber *)gid
{
    GetGaschargeInfoOp *op = [GetGaschargeInfoOp operation];
    RACSignal *sig = [[op rac_postRequest] map:^id(GetGaschargeInfoOp *op) {
        GasCard *card = [self.cache objectForKey:op.req_gid];
        if (!card) {
            card = [[GasCard alloc] init];
            card.gid = op.req_gid;
            [self.cache addObject:card forKey:op.req_gid];
        }
        card.availablechargeamt = op.rsp_availablechargeamt;
        card.couponedmoney = op.rsp_couponedmoney;
        return card;
    }];
    return [CKStoreEvent eventWithSignal:sig code:kGasGetCardNormalInfo object:nil];
}

- (CKStoreEvent *)getCardCZBInfoByGID:(NSNumber *)gid CZBID:(NSNumber *)cid
{
    GetCZBGaschargeInfoOp *op = [GetCZBGaschargeInfoOp operation];
    op.req_gid = gid;
    op.req_cardid = cid;
    RACSignal *sig = [[op rac_postRequest] map:^id(GetCZBGaschargeInfoOp *op) {
        GasCard *card = [self.cache objectForKey:op.req_gid];
        if (!card) {
            card = [[GasCard alloc] init];
            card.gid = op.req_gid;
            [self.cache addObject:card forKey:op.req_gid];
        }
        card.availablechargeamt = op.rsp_availablechargeamt;
        card.couponedmoney = op.rsp_couponedmoney;
        card.czbdiscountrate = op.rsp_discountrate;
        card.czbcouponupplimit = op.rsp_couponupplimit;
        card.czbcouponedmoney = op.rsp_czbcouponedmoney;
        return card;
    }];
    return [CKStoreEvent eventWithSignal:sig code:kGasGetCardCZBInfo object:nil];
}

- (void)reloadDataWithCode:(NSInteger)code
{
    
}

@end
