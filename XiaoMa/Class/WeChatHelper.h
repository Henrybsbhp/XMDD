//
//  WeChatHelper.h
//  XiaoMa
//
//  Created by jt on 15-4-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WXApiObject.h"

#define APP_ID          @"wxf346d7a6113bbbf9"
#define APP_SECRET      @"03cdb23781343412055c579103dedf9f" 
//商户号，填写商户对应参数
#define MCH_ID          @"1238430202"
//商户API密钥，填写相应参数
#define PARTNER_ID      @"X1XDBAfEgd2CaYc9dYcyTwrXpmK5JzFx"
//支付结果回调页面
#define NOTIFY_URL      @"http://183.129.253.170:18282/paa/weichatpaynotify"
//获取服务器端支付数据地址（商户自定义）
#define SP_URL          @"http://wxpay.weixin.qq.com/pub_v2/app/app_pay.php"

@interface WeChatHelper : NSObject

/// 微信支付结果信号 9000,dismiss,
@property (nonatomic,strong)RACSubject * rac_wechatResultSignal;

+ (instancetype)sharedHelper;

- (void)payOrdWithTradeNo:(NSString *)TradeNO andProductName:(NSString *)pName andPrice:(float_t)price;

@end
