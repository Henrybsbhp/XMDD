//
//  WeChatHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "WeChatHelper.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "Xmdd.h"
#import "GetPayStatusOp.h"

@interface WeChatHelper ()<WXApiDelegate>

@end

@implementation WeChatHelper

- (void)dealloc
{
    DebugLog(@"WeChatHelper dealloc");
}

- (RACSignal *)rac_payWithPayInfo:(WechatPayInfo *)wxPayInfo andTradeNO:(NSString *)tn
{
    //调起微信支付
    PayReq *req             = [[PayReq alloc] init];
    req.openID              = [wxPayInfo.payInfo objectForKey:@"appid"];
    req.partnerId           = [wxPayInfo.payInfo objectForKey:@"partnerid"];
    req.prepayId            = [wxPayInfo.payInfo objectForKey:@"prepayid"];
    req.nonceStr            = [wxPayInfo.payInfo objectForKey:@"noncestr"];
    req.timeStamp           = [[wxPayInfo.payInfo objectForKey:@"timestamp"] intValue];
    req.package             = [wxPayInfo.payInfo objectForKey:@"prepayidpackage"];
    req.sign                = [wxPayInfo.payInfo objectForKey:@"sign"];
    
    [WXApi sendReq:req];
    [self startHandleWeChatPaymentOnce];
    
    RACSignal *sig = [[[self rac_signalForSelector:@selector(onResp:) fromProtocol:@protocol(WXApiDelegate)] take:1] flattenMap:^RACStream *(RACTuple *tuple) {
        
        BaseResp *resp = [tuple first];
        if (![resp isKindOfClass:[PayResp class]]) {
            return [RACSignal empty];
        }
        if (resp.errCode == WXSuccess) {
            return [RACSignal return:@"9000"];
        }
        else if (resp.errCode == WXErrCodeUserCancel) {
            return [RACSignal empty];
        }
        
        
        return [RACSignal error:[NSError errorWithDomain:@"微信支付失败" code:resp.errCode userInfo:nil]];
    }];
    
    // 微信支付，支付成功后，使用左上角iOS返回键返回，导致不调用微信SDK回调。
    RACSignal * enterForegroundSign = [[gAppDelegate rac_signalForSelector:@selector(applicationWillEnterForeground:)] flattenMap:^RACStream *(id value) {
        
        return  [self rac_getTradeStatus:tn];
    }];
    
    RACSignal * signal = [[sig merge:enterForegroundSign] take:1];
    
    return signal;
}

- (void)startHandleWeChatPaymentOnce
{
    [[[[gAppDelegate rac_signalForSelector:@selector(application:handleOpenURL:)] filter:^BOOL(RACTuple *tuple) {
        NSURL *url = [tuple second];
        return [WXApi handleOpenURL:url delegate:self];
    }] take:1] subscribeNext:^(id x) {
        DebugLog(@"start Handle WeChatPayment!");
    }];
}

- (RACSignal *)rac_getTradeStatus:(NSString *)tradeid
{
    GetPayStatusOp *op = [[GetPayStatusOp alloc]init];
    if (tradeid.length && self.tradeType)
    {
        op.req_tradeno = tradeid;
        op.req_tradetype = [NSString stringWithFormat:@"%lu",(unsigned long)self.tradeType];
        
        return [op rac_postRequest];
    }
    return nil;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp
{
}
@end
