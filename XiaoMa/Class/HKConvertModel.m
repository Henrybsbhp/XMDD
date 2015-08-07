//
//  HKConvertModel.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKConvertModel.h"

@implementation HKConvertModel

+ (NSMutableString *)convertCardNumberForEncryption:(NSString *)card
{
    NSMutableString *str = [NSMutableString string];
    [str safetyAppendString:card];
    if (str.length > 4) {
        NSMutableString *templateStr = [NSMutableString string];
        for (int i = 0; i < card.length-4; i++) {
            [templateStr appendString:@"*"];
        }
        [str replaceCharactersInRange:NSMakeRange(0, card.length-4) withString:templateStr];
        for (int i = 4; i < str.length; i += 4) {
            [str insertString:@" " atIndex:i];
            i++;
        }
    }
    return str;
}

@end
