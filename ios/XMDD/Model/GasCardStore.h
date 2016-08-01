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

- (HKStoreEvent *)getAllCards;
- (HKStoreEvent *)getAllCardsIfNeeded;
- (HKStoreEvent *)deleteCardByGID:(NSNumber *)gid;
- (HKStoreEvent *)addCard:(GasCard *)card;
- (HKStoreEvent *)updateCardInfoByGID:(NSNumber *)gid;
- (RACSignal *)rac_getCardNormalInfoByGID:(NSNumber *)gid;

@end
