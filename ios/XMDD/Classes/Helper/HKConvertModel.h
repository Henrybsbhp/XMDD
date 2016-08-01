//
//  HKConvertModel.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKConvertModel : NSObject

///隐藏银行卡号，只保留后4位
+ (NSMutableString *)convertCardNumberForEncryption:(NSString *)card;
///隐藏手机号码的中间4位
+ (NSString *)convertPhoneNumberForEncryption:(NSString *)phone;

@end
