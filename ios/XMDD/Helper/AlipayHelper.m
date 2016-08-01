//
//  AlipayHelper.m
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "AlipayHelper.h"
#import <AlipaySDK/AlipaySDK.h>

#define XMDDAlipayScheme @"com.huika.xmdd.alipay"

@implementation AlipayHelper


- (void)dealloc
{
    NSLog(@"AlipayHelper dealloc");
}

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn alipayInfo:(NSString *)alipayInfo
{
    //从支付宝网页返回回调
    RACSignal *sig1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[AlipaySDK defaultService] payOrder:alipayInfo fromScheme:XMDDAlipayScheme callback:^(NSDictionary *resultDic) {
            
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
        
        RACSignal * signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                
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
        
        return signal;
    }];
    
    return [[sig1 merge:sig2] take:1];
}


@end
