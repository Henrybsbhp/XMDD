//
//  UPPayHelper.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "UPPayHelper.h"
#import "UPPayPlugin.h"

//接入模式  "00":代表生产环境   "01":代表测试环境、
#ifdef DEBUG
    #define UPPayPaymentMode  @"01"
#else
    #define UPPayPaymentMode  @"00"
#endif

@interface UPPayHelper ()<UPPayPluginDelegate>
@end

@implementation UPPayHelper

- (void)dealloc
{
    
}

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc
{
    
    [UPPayPlugin startPay:tn mode:UPPayPaymentMode viewController:tvc delegate:self];
    return [[[self rac_signalForSelector:@selector(UPPayPluginResult:) fromProtocol:@protocol(UPPayPluginDelegate)] take:1] flattenMap:^RACStream *(RACTuple *tuple) {
        NSString *result = [tuple first];
        if ([@"success" isEqualToString:result]) {
            return [RACSignal return:result];
        }
        else if ([@"fail" isEqualToString:result]) {
            return [RACSignal error:[NSError errorWithDomain:@"银联支付失败" code:0 userInfo:nil]];
        }
        return [RACSignal empty];
    }];
}

- (void)UPPayPluginResult:(NSString *)result
{
}

@end
