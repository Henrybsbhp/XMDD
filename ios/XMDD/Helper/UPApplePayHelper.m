//
//  UPApplePayHelper.m
//  XiaoMa
//
//  Created by St.Jimmy on 7/19/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "UPApplePayHelper.h"


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
    DebugLog(@"UPApplePayHelper dealloc");
}

+ (BOOL)isApplePayAvailable
{
    if (![PKPaymentAuthorizationViewController class]) {
        // 检查系统版本支持性
        return NO;
        
    } else if (![PKPaymentAuthorizationViewController canMakePayments]) {
        // 检查设备支持性
        return NO;
        
    } else if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkChinaUnionPay]]) {
        // 检查卡片支持性
        return NO;
        
    } else {
        return YES;
    }
}

- (RACSignal *)rac_applePayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc
{
    [UPAPayPlugin startPay:tn mode:UPApplePayPaymentMode viewController:tvc delegate:self andAPMechantID:@"merchant.com.huika.xmdd"];
    
    return [[[self rac_signalForSelector:@selector(UPAPayPluginResult:) fromProtocol:@protocol(UPAPayPluginDelegate)] take:1] flattenMap:^RACStream *(RACTuple *tuple) {
        UPPayResult *payResult = [tuple first];
        if (payResult.paymentResultStatus == UPPaymentResultStatusSuccess) {
            return [RACSignal return:payResult];
        } else if (payResult.paymentResultStatus == UPPaymentResultStatusFailure) {
            return [RACSignal error:[NSError errorWithDomain:payResult.errorDescription ?: @"" code:payResult.paymentResultStatus userInfo:nil]];
        }
        
        return [RACSignal empty];
    }];
}

- (void)UPAPayPluginResult:(UPPayResult *)payResult
{
    
}

@end
