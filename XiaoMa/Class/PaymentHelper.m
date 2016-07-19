//
//  PaymentManager.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PaymentHelper.h"
#import "UPPayHelper.h"
#import "AlipayHelper.h"
#import "WeChatHelper.h"
#import "UPApplePayHelper.h"

@interface PaymentHelper ()
@property (nonatomic, strong) id helper;
@end
@implementation PaymentHelper

- (void)dealloc
{
    self.helper = nil;
}

- (void)resetForAlipayWithTradeNumber:(NSString *)tn alipayInfo:(NSString *)alipayInfo
{
    _platformType = PaymentPlatformTypeAlipay;
    _tradeNumber = tn;
    _alipayInfo = alipayInfo;
}

- (void)resetForWeChatWithTradeNumber:(NSString *)tn andPayInfoModel:(WechatPayInfo *)wechatPayInfo andTradeType:(TradeType)type
{
    _platformType = PaymentPlatformTypeWeChat;
    _tradeNumber = tn;
    _wechatPayInfo = wechatPayInfo;
    _tradeType = type;
}

- (void)resetForUPPayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc
{
    _platformType = PaymentPlatformTypeUPPay;
    _tradeNumber = tn;
    _targetVC = tvc;
}

- (void)resetForUPApplePayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc
{
    _platformType = PaymentPlatformTypeApplePay;
    _tradeNumber = tn;
    _targetVC = tvc;
}

- (RACSignal *)rac_startPay2
{
    RACSubject *subject = [RACSubject subject];
    __block BOOL success = NO;
    [[self rac_startPay] subscribeNext:^(id x) {
        success = YES;
        [subject sendNext:x];
    } error:^(NSError *error) {
        success = YES;
        [subject sendError:error];
    } completed:^{
        if (!success) {
            [subject sendError:[NSError errorWithDomain:@"订单取消" code:333 userInfo:nil]];
        }
        else {
            [subject sendCompleted];
        }
    }];
    return subject;
}


- (RACSignal *)rac_startPay
{
    RACSignal *signal;
    //银联支付
    if (_platformType == PaymentPlatformTypeUPPay) {
        UPPayHelper *helper = [[UPPayHelper alloc] init];
        signal = [helper rac_payWithTradeNumber:self.tradeNumber targetVC:self.targetVC];
        self.helper = helper;
    }
    //支付宝支付
    else if (_platformType == PaymentPlatformTypeAlipay) {
        AlipayHelper *helper = [[AlipayHelper alloc] init];
        signal = [helper rac_payWithTradeNumber:self.tradeNumber alipayInfo:self.alipayInfo];
        self.helper = helper;
    }
    //微信支付
    else if (_platformType == PaymentPlatformTypeWeChat) {
        WeChatHelper *helper = [[WeChatHelper alloc] init];
        helper.tradeType = self.tradeType;
        signal = [helper rac_payWithPayInfo:self.wechatPayInfo andTradeNO:self.tradeNumber];
        self.helper = helper;
    }
    // ApplePay支付
    else if (_platformType == PaymentPlatformTypeApplePay) {
        UPApplePayHelper *helper = [[UPApplePayHelper alloc] init];
        signal = [helper rac_applePayWithTradeNumber:self.tradeNumber targetVC:self.targetVC];
        self.helper = helper;
    }
    
    return [[signal map:^id(id value) {
        return self;
    }] catch:^RACSignal *(NSError *error) {
        
        return [RACSignal error:error];
    }];
}

+ (int)paymentChannelForPlatformType:(PaymentPlatformType)platformType
{
    switch (platformType) {
        case PaymentPlatformTypeAlipay: return 2;
        case PaymentPlatformTypeWeChat: return 3;
        case PaymentPlatformTypeUPPay: return 8;
        case PaymentPlatformTypeCreditCard: return 7;
        case PaymentPlatformTypeApplePay: return 9;
    }
    return 0;
}

@end
