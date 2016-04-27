//
//  WeChatHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "WeChatHelper.h"
#import "payRequsestHandler.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "XiaoMa.h"
#import "GetPayStatusOp.h"

@interface WeChatHelper ()<WXApiDelegate>

@end

@implementation WeChatHelper

- (void)dealloc
{
    NSLog(@"WeChatHelper dealloc");
}

- (RACSignal *)rac_payWithTradeNumber:(NSString *)tn productName:(NSString *)pn price:(CGFloat)price
{
    //创建支付签名对象
    payRequsestHandler *reqHandler = [payRequsestHandler alloc];
    //初始化支付签名对象
    [reqHandler init:WECHAT_APP_ID mch_id:WECHAT_MCH_ID];
    //设置密钥
    [reqHandler setKey:WECHAT_PARTNER_ID];
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [reqHandler sendPayWithTradeNo:tn andProductName:pn andPrice:price];
    if(dict == nil){
        //错误提示
        NSString *debug = [reqHandler getDebugifo];
        DebugLog(@"%@WeChatPay:%@",kErrPrefix,debug);
        return [RACSignal error:[NSError errorWithDomain:debug code:0 userInfo:nil]];
    }
    DebugLog(@"WeChatPay:%@",[reqHandler getDebugifo]);
    
    //调起微信支付
    PayReq *req             = [[PayReq alloc] init];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = [(NSString *)[dict objectForKey:@"timestamp"] intValue];
    req.package             = [dict objectForKey:@"package"];
    req.sign                = [dict objectForKey:@"sign"];
    
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
