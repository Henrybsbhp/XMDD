//
//  GasCZBVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasCZBVM.h"

@implementation GasCZBVM

- (NSArray *)datasource
{
//    self.isLoadSuccess = YES;
//    self.curGasCard = [[GasCard alloc] init];
//    self.curGasCard.czbcouponupplimit = 50;
//    self.curGasCard.czbcouponedmoney = 8;
//    self.curGasCard.cardtype = 2;
//    self.curBankCard = [[HKBankCard alloc] init];
//    
    if (!self.isLoadSuccess) {
        return @[@[@"1"]];
    }
    NSString *row1 = self.curBankCard ? @"10005" : @"10006";
    NSString *row2 = self.curGasCard ? @"10001" : @"10002";
    return @[@[row1,row2,@"10003",@"10004"]];
}

- (NSString *)bankFavorableDesc
{
    if (self.curBankCard && self.curGasCard) {
        return [NSString stringWithFormat:@"该汽车卡可享受充值返利%d%%的优惠，最高返利%d元。",
                self.curGasCard.czbdiscountrate, self.curGasCard.czbcouponupplimit];
    }
    return @"添加浙商银行汽车卡后，既可享受金卡返利8%，最高返50元；白金卡返利15%，最高返100元。";
}

@end
