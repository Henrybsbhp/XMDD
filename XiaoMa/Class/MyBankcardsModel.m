//
//  MyBankcardsModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyBankcardsModel.h"
#import "GetBankcardListOp.h"

@implementation MyBankcardsModel

- (void)addBankcard:(HKBankCard *)card
{
    [[self cardCache] addObject:card forKey:card.cardID];
    [self updateCache:self.cache refreshTime:NO];
}

- (void)removeCarByID:(NSString *)cardid
{
    [[self cardCache] removeObjectForKey:cardid];
    [self updateCache:self.cache refreshTime:NO];
}

- (JTQueue *)cardCache
{
    return self.cache;
}


- (NSArray *)bankcards
{
    return [(JTQueue *)self.cache allObjects];
}

- (RACSignal *)rac_requestData
{
    GetBankcardListOp *op = [GetBankcardListOp operation];
    return [[op rac_postRequest] map:^id(GetBankcardListOp *op) {
        JTQueue *queue = [[JTQueue alloc] init];
        for (HKBankCard *card in op.rsp_bankcards) {
            [queue addObject:card forKey:card.cardID];
        }
        return queue;
    }];
}

@end
