//
//  BankStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/4.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "UserStore.h"
#import "CKQueue.h"

#define kEvtGetAllBankCards       @"getAllBankCards"

#define kDomainBankCards          @"bankCards"

@interface BankStore : UserStore

@property (nonatomic, strong) CKQueue *bankCards;

///获取当前用户的所有银行卡
- (CKEvent *)getAllBankCards;
- (CKEvent *)getAllBankCardsIfNeeded;

@end
