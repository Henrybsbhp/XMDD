//
//  BankStore.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BankStore.h"
#import "UnbindBankcardOp.h"
#import "GetBankCardListV2Op.h"
#import "MyBankCard.h"

@implementation BankStore

- (void)dealloc
{
}

- (void)reloadForUserChanged:(JTUser *)user
{
    self.bankCards = nil;
    if (user) {
        [[self getAllCZBBankCards] send];
    }
}

#pragma mark - Event
///获取当前用户的所有银行卡
- (CKEvent *)getAllCZBBankCards
{
    CKEvent *event;
    if (!gAppMgr.myUser) {
        event = [[RACSignal return:nil] eventWithName:@"reloadUser"];
    }
    else {
        event = [[self rac_getAllCZBBankCards] eventWithName:kEvtGetAllBankCards];
    }
    return [self inlineEvent:event forDomain:kDomainBankCards];
}


- (CKEvent *)getAllCZBBankCardsIfNeeded
{
    if ([self needUpdateTimetagForKey:nil]) {
        return [self getAllCZBBankCards];
    }
    return [CKEvent eventWithName:kEvtGetAllBankCards signal:nil];;
}


- (CKEvent *)deleteBankCardByCID:(NSNumber *)cid vcode:(NSString *)vcode
{
    CKEvent *event = [[self rac_deleteBankCardByCID:cid vcode:vcode] eventWithName:kEvtDeleteBankCard];
    return [self inlineEvent:event forDomain:kDomainBankCards];
}


#pragma mark - Signal
- (RACSignal *)rac_getAllCZBBankCards
{
    GetBankCardListV2Op *op = [GetBankCardListV2Op operation];
    op.req_cardType = 1;
    @weakify(self);
    return [[[op rac_postRequest] map:^id(GetBankCardListV2Op *op) {
        @strongify(self);
        JTQueue *cache = [[JTQueue alloc] init];
        for (MyBankCard *card in op.rsp_cardArray) {
            MyBankCard *oldCard = [self.bankCards objectForKey:card.tokenID];
            card.gasInfo = oldCard.gasInfo;
            [cache addObject:card forKey:card.tokenID];
        }
        self.bankCards = cache;
        [self updateTimetagForKey:nil];
        return op.rsp_cardArray;
    }] replayLast];
}


- (RACSignal *)rac_deleteBankCardByCID:(NSNumber *)cid vcode:(NSString *)vcode
{
    UnbindBankcardOp *op = [UnbindBankcardOp operation];
    op.req_vcode = vcode;
    op.req_cardid = cid;
    @weakify(self);
    return [[[op rac_postRequest] map:^id(id value) {
        @strongify(self);
        NSInteger index = [self.bankCards indexOfObjectForKey:cid];
        MyBankCard *card = [self.bankCards objectAtIndex:index];
        if (card) {
            [self.bankCards removeObjectAtIndex:index];
            NSNumber *indexNumber = index != NSNotFound ? @(index) : nil;
            return RACTuplePack(cid, indexNumber);
        }
        return nil;
    }] replayLast];
}


@end
