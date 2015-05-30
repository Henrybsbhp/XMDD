//
//  AlipayHelper.m
//  HappyTrain
//
//  Created by jt on 14-10-23.
//  Copyright (c) 2014年 jtang. All rights reserved.
//

#import "AlipayHelper.h"


#define AlipayCallbackDefaultUrlForDebug   @"http://183.129.253.170:18282/paa/alipaynotify"
#define AlipayCallbackDefaultUrlForRelease   @"http://api.xiaomadada.com:8282/paa/alipaynotify"

#define XMDDAlipayScheme @"com.huika.xmdd.alipay"

@implementation AlipayHelper

@synthesize result = _result;

+ (instancetype)sharedHelper
{
    static AlipayHelper *g_alipayHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        g_alipayHelper = [[AlipayHelper alloc] init];
    });
    return g_alipayHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _rac_alipayResultSignal = [RACSubject subject];
        _result = @selector(paymentResult:);
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"AlipayHelper dealloc");
}

- (void)payOrdWithTradeNo:(NSString *)TradeNO andProductName:(NSString *)pName
    andProductDescription:(NSString *)pDescription andPrice:(float_t)price
{
    
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    order.partner = PartnerID;
    order.seller = SellerID;
    
    order.tradeNO = TradeNO; //订单ID
    order.productName = pName ; //商品标题
    order.productDescription = pDescription; //商品描述
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
    
#ifdef DEBUG
    order.amount = [NSString stringWithFormat:@"%.2f",0.01]; //商品价格
//    order.notifyURL = gApplicationInfo.userConfigInfo.alipayCallbackUrl.length ?
//    gApplicationInfo.userConfigInfo.alipayCallbackUrl:AlipayCallbackDefaultUrlForDebug; //回调URL
    order.notifyURL = AlipayCallbackDefaultUrlForDebug;
#else
    order.amount = [NSString stringWithFormat:@"%.2f",price]; //商品价格
//    order.notifyURL =  gApplicationInfo.userConfigInfo.alipayCallbackUrl.length ?
//    gApplicationInfo.userConfigInfo.alipayCallbackUrl :AlipayCallbackDefaultUrlForRelease;
    order.notifyURL = AlipayCallbackDefaultUrlForRelease;
#endif

    NSString *orderInfo = [order description];
    
    NSString * signedStr = [AlipayHelper doRsa:orderInfo];
    
    NSString *orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                             orderInfo, signedStr, @"RSA"];
    
    if (signedStr != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderInfo, signedStr, @"RSA"];
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:XMDDAlipayScheme callback:^(NSDictionary *resultDic) {
            
            int resultCode = [resultDic[@"resultStatus"] intValue];
            NSString * resultMsg = resultDic[@"result"];
            
            if(resultCode == 9000)
            {
                [gAlipayHelper.rac_alipayResultSignal sendNext:@"9000"];
            }
            else
            {
                [gAlipayHelper.rac_alipayResultSignal sendError:[NSError errorWithDomain:resultMsg code:resultCode userInfo:nil]];
            }
        }];
        
    }
    
//    [AlixLibService payOrder:orderString AndScheme:HTAlipayScheme seletor:_result target:self];
}


//wap回调函数
- (void)paymentResult:(NSString *)resultd
{
    //结果处理
#if ! __has_feature(objc_arc)
    AlixPayResult* result = [[[AlixPayResult alloc] initWithString:resultd] autorelease];
#else
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultd];
#endif
    if (result)
    {
        
        if (result.statusCode == 9000)
        {
            /*
             *用公钥验证签名 严格验证请使用result.resultString与result.signString验签
             */
            
            //交易成功
            NSString* key = AlipayPubKey;//签约帐户后获取到的支付宝公钥
            id<DataVerifier> verifier;
            verifier = CreateRSADataVerifier(key);
            
            if ([verifier verifyString:result.resultString withSign:result.signString])
            {
                [gAlipayHelper.rac_alipayResultSignal sendNext:@"9000"];
                //验证签名成功，交易结果无篡改
            }
            else
            {
                [gAlipayHelper.rac_alipayResultSignal sendError:[NSError errorWithDomain:@"验证签名失败，交易结果被篡改" code:8999 userInfo:nil]];
            }
        }
        else
        {
            [self.rac_alipayResultSignal sendError:[NSError errorWithDomain:result.statusMessage code:result.statusCode userInfo:nil]];
        }
    }
    else
    {
        [self.rac_alipayResultSignal sendError:[NSError errorWithDomain:result.statusMessage code:result.statusCode userInfo:nil]];
    }
    
}

-(void)paymentResultDelegate:(NSString *)result
{
    NSLog(@"%@",result);
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
