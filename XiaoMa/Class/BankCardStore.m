//
//  BankCardStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BankCardStore.h"
#import "GetBankcardListOp.h"
#import "GetCZBGaschargeInfoOp.h"
#import "UnbindBankcardOp.h"

@implementation BankCardStore

- (void)dealloc
{
    
}

- (HKStoreEvent *)getAllBankCards
{
    GetBankcardListOp *op = [GetBankcardListOp operation];
    @weakify(self);
    RACSignal *sig = [[[op rac_postRequest] map:^id(GetBankcardListOp *op) {
        @strongify(self);
        JTQueue *cache = [[JTQueue alloc] init];
        for (HKBankCard *card in op.rsp_bankcards) {
            HKBankCard *oldCard = [self.cache objectForKey:card.cardID];
            card.gasInfo = oldCard.gasInfo;
            [cache addObject:card forKey:card.cardID];
        }
        self.cache = cache;
        [self updateTimetagForKey:nil];
        return op.rsp_bankcards;
    }] replayLast];
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventGet object:nil];
}

- (HKStoreEvent *)getAllBankCardsIfNeeded
{
    if ([self needUpdateTimetagForKey:nil]) {
        return [self getAllBankCards];
    }
    return [HKStoreEvent eventWithSignal:[RACSignal return:self.cache.allObjects] code:kHKStoreEventNone object:nil];
}

- (HKStoreEvent *)deleteBankCardByCID:(NSNumber *)cid vcode:(NSString *)vcode
{
    UnbindBankcardOp *op = [UnbindBankcardOp operation];
    op.req_vcode = vcode;
    op.req_cardid = cid;
    @weakify(self);
    RACSignal *sig = [[[op rac_postRequest] map:^id(id value) {
        @strongify(self);
        NSInteger index = [self.cache indexOfObjectForKey:cid];
        [self.cache removeObjectForKey:cid];
        NSNumber *indexNumber = index != NSNotFound ? @(index) : nil;
        return RACTuplePack(cid, indexNumber);
    }] replayLast];
    
    return [HKStoreEvent eventWithSignal:sig code:kHKStoreEventDelete object:nil];
}

- (void)reloadDataWithCode:(NSInteger)code
{
    [self sendEvent:[HKStoreEvent eventWithSignal:[[self getAllBankCards] signal] code:kHKStoreEventReload object:nil]];
}

- (HKStoreEvent *)updateBankCardCZBInfoByCID:(NSNumber *)cid
{
    return [self sendEvent:[HKStoreEvent eventWithSignal:[self rac_getCardCZBInfoByCID:cid] code:kHKStoreEventUpdate object:nil]];
}

- (RACSignal *)rac_getCardCZBInfoByCID:(NSNumber *)cid
{
    GetCZBGaschargeInfoOp *op = [GetCZBGaschargeInfoOp operation];
    op.req_cardid = cid;
    @weakify(self);
    RACSignal *sig = [[[op rac_postRequest] map:^id(GetCZBGaschargeInfoOp *op) {
        @strongify(self);
        HKBankCard *card = [self.cache objectForKey:cid];
        card.gasInfo = op;
        return op;
    }] replay];
    return sig;
}
@end
