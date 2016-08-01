//
//  HKBank.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/7.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GetCZBGaschargeInfoOp.h"
typedef enum : NSInteger
{
    HKBankTypeUnknow = 0,
    HKBankTypeCZB               //浙商银行
}HKBankType;

typedef enum : NSInteger
{
    HKBankCardTypeCredit = 0,   //信用卡
    HKBankCardTypeDespoit       //储蓄卡
}HKBankCardType;

@interface HKBankCard : NSObject<NSCopying>

@property (nonatomic, assign) HKBankType bankType;
@property (nonatomic, assign) HKBankCardType cardType;
@property (nonatomic, strong) NSNumber *cardID;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSArray  *couponIds;
///加油信息
@property (nonatomic, strong) GetCZBGaschargeInfoOp *gasInfo;

+ (instancetype)bankCardWithJSONResponse:(NSDictionary *)rsp;
- (NSString *)cardName;

@end
