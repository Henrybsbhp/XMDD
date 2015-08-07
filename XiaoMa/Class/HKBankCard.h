//
//  HKBank.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSInteger
{
    HKBankTypeCZB               //浙商银行
}HKBankType;

typedef enum : NSInteger
{
    HKBankCardTypeCredit = 0,   //信用卡
    HKBankCardTypeDespoit       //储蓄卡
}HKBankCardType;

@interface HKBankCard : NSObject
@property (nonatomic, assign) HKBankType bankType;
@property (nonatomic, assign) HKBankCardType cardType;
@property (nonatomic, strong) NSString *cardName;
@property (nonatomic, strong) NSString *cardNumber;

@end
