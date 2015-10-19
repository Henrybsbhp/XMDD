//
//  GasVM.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasNormalVM.h"

@implementation GasNormalVM

- (NSArray *)datasource
{
    self.isLoadSuccess = YES;
    self.curGasCard = [[GasCard alloc] init];
    self.curGasCard.gascardno = @"1234567";
    self.curGasCard.cardtype = 1;
    if (!self.isLoadSuccess) {
        return @[@[@"1"]];
    }
    NSString *row1 = self.curGasCard ? @"10001" : @"10002";
    return @[@[row1,@"10003",@"10004"],@[@"20001",@"20002",@"20003"]];
}

- (NSString *)rechargeFavorableDesc
{
    return @"<font size=20 color='#CCFF00'>Text with</font> <font size=16 color=purple>different colours 货航哦哦</font> <font face=Futura size=32 color='#dd1100'>and sizes</font>";
}

@end
