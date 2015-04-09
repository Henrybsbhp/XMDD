//
//  JTUser.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "JTUser.h"
#import "XiaoMa.h"

@implementation JTUser

- (NSArray *)paymentTypes
{
    NSMutableArray *types = [NSMutableArray array];
    if (self.carwashTicketsCount.integerValue > 0) {
        [types safetyAddObject:RACTuplePack(@(PaymentTypeCarwashTicket), self.carwashTicketsCount)];
    }
    if (self.abcCarwashTimesCount.integerValue > 0) {
        [types safetyAddObject:RACTuplePack(@(PaymentTypeABCBankCarwashTimes), self.abcCarwashTimesCount)];
    }
    if (self.abcIntegral.integerValue > 0) {
        [types safetyAddObject:RACTuplePack(@(PaymentTypeABCBankIntegral), self.abcIntegral)];
    }
    
    return types;
}

@end

