//
//  BankStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BankStore.h"
#import "GetBankcardListOp.h"

@implementation BankStore

#pragma mark - Event
///获取当前用户的所有银行卡
- (CKEvent *)getAllBankCards
{
    CKEvent *event = [[self rac_getAllBankCards] eventWithName:kEvtGetAllBankCards];
    return [self inlineEvent:event forDomain:kDomainBankCards];
}

- (CKEvent *)getAllBankCardsIfNeeded
{
    if ([self needUpdateTimetagForKey:nil]) {
        return [self getAllBankCards];
    }
    return nil;
}

#pragma mark - Signal
- (RACSignal *)rac_getAllBankCards
{
    GetBankcardListOp *op = [GetBankcardListOp operation];
    @weakify(self);
    return [[[op rac_postRequest] map:^id(GetBankcardListOp *op) {
        @strongify(self);
        CKQueue *cache = [CKQueue queue];
        for (HKBankCard *card in op.rsp_bankcards) {
            HKBankCard *oldCard = [self.bankCards objectForKey:card.cardID];
            card.gasInfo = oldCard.gasInfo;
            [cache addObject:card forKey:card.cardID];
        }
        self.bankCards = cache;
        [self updateTimetagForKey:nil];
        return op.rsp_bankcards;
    }] replayLast];
}

@end
