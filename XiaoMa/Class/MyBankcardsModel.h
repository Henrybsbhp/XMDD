//
//  MyBankcardsModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CacheModel.h"
#import "HKBankCard.h"

@interface MyBankcardsModel : CacheModel

- (void)addBankcard:(HKBankCard *)card;
- (void)removeCarByID:(NSString *)cardid;
- (NSArray *)bankcards;

@end
