//
//  AlipayHelper.m
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "AlipayHelper.h"
#import "XiaoMa.h"
#import "AlipayConfig.h"
#import "DataSigner.h"
#import "AlixPayResult.h"
#import "DataVerifier.h"
#import "AlixPayOrder.h"
#import <AlipaySDK/AlipaySDK.h>

#define XMDDAlipayScheme @"com.huika.xmdd.alipay"

@implementation AlipayHelper


- (void)dealloc
{
    NSLog(@"AlipayHelper dealloc");
}

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn productName:(NSString *)pn
                   productDescription:(NSString *)pd price:(CGFloat)price
{
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
    
    order.tradeNO = tn; //订单ID
    order.productName = pn; //商品标题
    order.productDescription = pd; //商品描述
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    order.notifyURL = ALIPAY_NOTIFY_URL;
    order.amount = [NSString stringWithFormat:@"%.2f", price];

    NSString *orderInfo = [order description];
    NSString * signedStr = [AlipayHelper doRsa:orderInfo];
    
    if (signedStr == nil) {
        return [RACSignal error:[NSError errorWithDomain:@"支付宝支付失败" code:0 userInfo:nil]];
    }
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];
    
    //从支付宝网页返回回调
    RACSignal *sig1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:XMDDAlipayScheme callback:^(NSDictionary *resultDic) {
            
            int resultCode = [resultDic[@"resultStatus"] intValue];
            NSString * resultMsg = resultDic[@"result"];
            
            if(resultCode == 9000) {
                [subscriber sendNext:@"9000"];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:[NSError errorWithDomain:resultMsg code:resultCode userInfo:nil]];
            }
        }];
        return nil;
    }];
    
    //从支付宝客户端返回回调
    RACSignal *sig2 = [[gAppDelegate rac_signalForSelector:@selector(application:handleOpenURL:)] flattenMap:^RACStream *(RACTuple *tuple) {
        NSURL *url = [tuple second];
        AlixPayResult *result = [self resultFromURL:url];
        if (result && result.statusCode == 9000)
        {
            //交易成功
            NSString* key = AlipayPubKey;
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            //验证签名成功，交易结果无篡改
            if ([verifier verifyString:result.resultString withSign:result.signString]) {
                return [RACSignal return:@"9000"];
            }
            else {
                return [RACSignal error:[NSError errorWithDomain:@"验证签名失败，交易结果被篡改" code:8999 userInfo:nil]];
            }
        }
        
        if (result)
        {
            return [RACSignal error:[NSError errorWithDomain:result.statusMessage code:result.statusCode userInfo:nil]];
        }
        else
        {
           return [RACSignal error:[NSError errorWithDomain:@"" code:8998 userInfo:nil]];
        }
    }];
    
    return [[sig1 merge:sig2] take:1];
}

- (AlixPayResult *)resultFromURL:(NSURL *)url {
    
    if (url != nil && [[url host] compare:@"safepay"] == 0) {
        NSString * query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [[AlixPayResult alloc] initWithString:query];
    }
    return nil;
}
#pragma mark - Alipay Function
+ (NSString*)doRsa:(NSString*)orderInfo
{
    id<DataSigner> signer;
    signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderInfo];
    return signedString;
}
@end
