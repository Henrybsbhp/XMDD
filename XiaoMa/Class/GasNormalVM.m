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
    if (!self.isLoadSuccess) {
        return @[@[@1]];
    }
    NSNumber *row1 = self.curGasCard ? @10001 : @10002;
    return @[@[row1,@10003,@10004],@[@20001,@20002,@20003]];
}

@end
