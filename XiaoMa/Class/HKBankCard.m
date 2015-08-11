//
//  HKBank.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKBankCard.h"

@implementation HKBankCard

+ (instancetype)bankCardWithJSONResponse:(NSDictionary *)rsp
{
    HKBankCard *card = [[HKBankCard alloc] init];
    card.cardNumber = rsp[@"bindcardno"];
    card.cardID = rsp[@"bid"];
    card.bankType = [self bankTypeForString:rsp[@"bankType"]];
    card.cardType = HKBankCardTypeCredit;
    return card;
}

+ (HKBankType)bankTypeForString:(NSString *)string
{
    if ([@"CZB" equalByCaseInsensitive:string]) {
        return HKBankTypeCZB;
    }
    return HKBankTypeUnknow;
}

- (NSString *)cardName
{
    if (self.cardType == HKBankCardTypeCredit) {
        return @"浙商银行 - 达达卡";
    }
    return nil;
}

@end
