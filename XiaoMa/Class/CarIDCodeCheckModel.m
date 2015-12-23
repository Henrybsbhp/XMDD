//
//  CarIDCodeCheckModel.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/12/21.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "CarIDCodeCheckModel.h"

@implementation CarIDCodeCheckModel

+ (BOOL)carIDCheckWithCodeStr:(NSString *)codeStr
{
    if (codeStr.length != 17) {
        return NO;
    }
    
    NSDictionary * vinDic = @{@"0":@"0", @"1":@"1", @"2":@"2",
                              @"3":@"3", @"4":@"4", @"5":@"5",
                              @"6":@"6", @"7":@"7", @"8":@"8",
                              @"9":@"9", @"A":@"1", @"B":@"2",
                              @"C":@"3", @"D":@"4", @"E":@"5",
                              @"F":@"6", @"G":@"7", @"H":@"8",
                              @"J":@"1", @"K":@"2", @"L":@"3",
                              @"M":@"4", @"N":@"5", @"P":@"7",
                              @"R":@"9", @"S":@"2", @"T":@"3",
                              @"U":@"4", @"V":@"5", @"W":@"6",
                              @"X":@"7", @"Y":@"8", @"Z":@"9"};
    
    NSArray * weightingArray = @[@8, @7, @6, @5, @4, @3, @2, @10, @0, @9, @8, @7, @6, @5, @4, @3, @2];
    
    NSInteger result = 0;
    for (int i = 0; i < codeStr.length; i ++) {
        if (i != 8) {
            NSString * key = [NSString stringWithFormat:@"%c", [codeStr characterAtIndex:i]];
            NSInteger value = [vinDic[key] integerValue];
            NSInteger weight = [weightingArray[i] integerValue];
            result = weight * value + result;
        }
    }
    if (result % 11 == [[NSString stringWithFormat:@"%c", [codeStr characterAtIndex:8]] integerValue]){
        return YES;
    }
    return NO;
}

@end
