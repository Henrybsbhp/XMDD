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
    card.cardNumber = rsp[@"cardno"];
    card.cardID = rsp[@"cardid"];
    card.bankType = [self bankTypeForString:rsp[@"bankType"]];
    card.cardType = HKBankCardTypeCredit;
    
    NSString * cids = rsp[@"cids"];
    NSMutableArray * tCids = [NSMutableArray array];
    for (NSString * cid in [cids componentsSeparatedByString:@","])
    {
        NSNumber * number = [NSNumber numberWithInteger:[cid integerValue]];
        [tCids safetyAddObject:number];
    }
    card.couponIds = [NSArray arrayWithArray:tCids];
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
        return @"浙商银行 - 汽车达人卡";
    }
    return nil;
}

@end
