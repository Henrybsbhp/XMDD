//
//  UPApplePayHelper.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/19/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "UPApplePayHelper.h"
#import <PassKit/PassKit.h>
#import "UPAPayPlugin.h"

// 接入模式  "00": 表示生产环境   "01": 表示测试环境
#ifdef DEBUG
    #define UPApplePayPaymentMode @"01"
#else
    #define UPApplePayPaymentMode @"00"
#endif

@interface UPApplePayHelper () <UPAPayPluginDelegate>

@end

@implementation UPApplePayHelper

- (void)dealloc
{
    
}

- (RACSignal *)rac_applePayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc
{
    if (![PKPaymentAuthorizationViewController class]) {
        //检查系统版本支持性
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前系统版本不支持 Pay，最低要求：iPhone 6, iOS 9.2 及以上。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    } else if (![PKPaymentAuthorizationViewController canMakePayments]) {
        //检查设备支持性
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前设备不支持 Pay，最低要求：iPhone 6, iOS 9.2 及以上。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        
    } else {
    
        [UPAPayPlugin startPay:tn mode:UPApplePayPaymentMode viewController:tvc delegate:self andAPMechantID:@"merchant.com.huika.xmdd"];
        
        return [[[self rac_signalForSelector:@selector(UPAPayPluginResult:) fromProtocol:@protocol(UPAPayPluginDelegate)] take:1] flattenMap:^RACStream *(RACTuple *tuple) {
            UPPayResult *payResult = [tuple first];
            if (payResult.paymentResultStatus == UPPaymentResultStatusSuccess) {
                return [RACSignal return:payResult];
            } else if (payResult.paymentResultStatus == UPPaymentResultStatusFailure) {
                return [RACSignal error:[NSError errorWithDomain:payResult.errorDescription code:payResult.paymentResultStatus userInfo:nil]];
            }
            
            return [RACSignal empty];
        }];
    }
    
    return [RACSignal empty];
}

- (void)UPAPayPluginResult:(UPPayResult *)payResult
{
    
}

@end
