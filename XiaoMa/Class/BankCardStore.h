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

- (CKStoreEvent *)getAllBankCards;
- (CKStoreEvent *)getAllBankCardsIfNeeded;
- (CKStoreEvent *)deleteBankCardByCID:(NSNumber *)cid vcode:(NSString *)vcode;
- (RACSignal *)rac_getCardCZBInfoByCID:(NSNumber *)cid;

@end
