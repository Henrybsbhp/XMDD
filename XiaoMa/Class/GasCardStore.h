//
//  GasCardStore.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKUserStore.h"
#import "GasCard.h"

#define kGasCardTimetagKey  @"GasCardTimetag"

@interface GasCardStore : HKUserStore

- (CKStoreEvent *)getAllCards;
- (CKStoreEvent *)getAllCardsIfNeeded;
- (CKStoreEvent *)deleteCardByGID:(NSNumber *)gid;
- (CKStoreEvent *)addCard:(GasCard *)card;
- (RACSignal *)rac_getCardNormalInfoByGID:(NSNumber *)gid;

@end
