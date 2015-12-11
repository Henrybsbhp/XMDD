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
#import "DeleteGascardOp.h"
#import "AddGascardOp.h"

@implementation GasCardStore

- (void)dealloc
{
    
}

- (HKStoreEvent *)getAllCards
{
    GetGascardListOp *op = [GetGascardListOp operation];
    @weakify(self);
    RACSignal *sig = [[[op rac_postRequest] map:^id(GetGascardListOp *rsp) {
        @strongify(self);
        for (GasCard *card in rsp.rsp_gascards) {
            GasCard *oldCard = [self.cache objectForKey:card.gid];
            if (oldCard) {
                [oldCard mergeSimpleGasCard:card];
            }
            else {
                [self.cache addObject:card forKey:card.gid];
            }
        }
        [self updateTimetagForKey:kGasCardTimetagKey];
        return rsp.rsp_gascards;
    }] replay];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventGet object:nil];
}

- (HKStoreEvent *)getAllCardsIfNeeded
{
    if ([self needUpdateTimetagForKey:kGasCardTimetagKey]) {
        return [self getAllCards];
    }
    
    return [HKStoreEvent eventWithSignal:[RACSignal return:[self.cache allObjects]] code:kHKStoreEventNone object:nil];
}

- (HKStoreEvent *)deleteCardByGID:(NSNumber *)gid
{
    DeleteGascardOp *op = [DeleteGascardOp operation];
    op.req_gid = gid;
    RACSignal *sig = [[[op rac_postRequest] map:^id(DeleteGascardOp *op) {
        NSInteger index = [self.cache indexOfObjectForKey:gid];
        [self.cache removeObjectForKey:gid];
        NSNumber *indexNumber = index != NSNotFound ? @(index) : nil;
        return RACTuplePack(gid, indexNumber);
    }] replay];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventDelete object:nil];
}

- (HKStoreEvent *)addCard:(GasCard *)card
{
    AddGascardOp *op = [AddGascardOp operation];
    op.req_cardtype = card.cardtype;
    op.req_gascardno = card.gascardno;
    RACSignal *sig = [[[op rac_postRequest] map:^id(AddGascardOp *op) {
        card.availablechargeamt = op.rsp_availablechargeamt;
        card.couponedmoney = op.rsp_couponedmoney;
        card.gid = op.rsp_gid;
        [self.cache addObject:card forKey:card.gid];
        return card;
    }] replay];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventAdd object:nil];
}

- (HKStoreEvent *)updateCardInfoByGID:(NSNumber *)gid
{
    RACSignal *sig = [self rac_getCardNormalInfoByGID:gid];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventUpdate object:nil];
}

- (RACSignal *)rac_getCardNormalInfoByGID:(NSNumber *)gid
{
    GetGaschargeInfoOp *op = [GetGaschargeInfoOp operation];
    op.req_gid = gid;
    @weakify(self);
    RACSignal *sig = [[[op rac_postRequest] map:^id(GetGaschargeInfoOp *op) {
        @strongify(self);
        GasCard *card = [self.cache objectForKey:op.req_gid];
        if (!card) {
            card = [[GasCard alloc] init];
            card.gid = op.req_gid;
            [self.cache addObject:card forKey:op.req_gid];
        }
        card.availablechargeamt = op.rsp_availablechargeamt;
        card.couponedmoney = op.rsp_couponedmoney;
        card.desc = op.rsp_desc;
        return card;
    }] replay];
    return sig;
}

- (void)reloadDataWithCode:(NSInteger)code
{
    [self sendEvent:[HKStoreEvent eventWithSignal:[[self getAllCards] signal] code:kHKStoreEventReload object:nil]];
}

@end
