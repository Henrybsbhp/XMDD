//
//  BankStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "JTQueue.h"

#define kEvtGetAllBankCards       @"getAllBankCards"
#define kEvtDeleteBankCard        @"deleteBankCardByCID"

#define kDomainBankCards          @"bankCards"

@interface BankStore : UserStore

@property (nonatomic, strong) JTQueue *bankCards;

///获取当前用户的所有银行卡
- (CKEvent *)getAllBankCards;
- (CKEvent *)getAllBankCardsIfNeeded;
- (CKEvent *)deleteBankCardByCID:(NSNumber *)cid vcode:(NSString *)vcode;

@end
