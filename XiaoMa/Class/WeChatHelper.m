//
//  WeChatHelper.m
//  XiaoMa
//
//  Created by jt on 15-4-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "WeChatHelper.h"
#import "payRequsestHandler.h"


@implementation WeChatHelper

+ (instancetype)sharedHelper
{
    static WeChatHelper *g_wechatHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^ {
        g_wechatHelper = [[WeChatHelper alloc] init];
    });
    return g_wechatHelper;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _rac_wechatResultSignal = [RACSubject subject];
    }
    return self;
}


- (void)dealloc
{
    NSLog(@"WeChatHelper dealloc");
}

- (void)payOrdWithTradeNo:(NSString *)TradeNO andProductName:(NSString *)pName andPrice:(float_t)price
{
#ifdef DEBUG
    price = 0.01;
#endif
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //}}}
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPayWithTradeNo:TradeNO andProductName:pName andPrice:price];
    
    if(dict == nil){
        //错误提示
        NSString *debug = [req getDebugifo];
        
//        [self alert:@"提示信息" msg:debug];
        
        NSLog(@"%@\n\n",debug);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        //[self alert:@"确认" msg:@"下单成功，点击OK后调起支付！"];
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
}

@end
