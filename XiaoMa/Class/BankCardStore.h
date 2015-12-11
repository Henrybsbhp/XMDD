//
//  BankCardStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"
#import "HKBankCard.h"

@interface BankCardStore : HKUserStore

- (HKStoreEvent *)getAllBankCards;
- (HKStoreEvent *)getAllBankCardsIfNeeded;
- (HKStoreEvent *)deleteBankCardByCID:(NSNumber *)cid vcode:(NSString *)vcode;
- (HKStoreEvent *)updateBankCardCZBInfoByCID:(NSNumber *)cid;
- (RACSignal *)rac_getCardCZBInfoByCID:(NSNumber *)cid;

@end
