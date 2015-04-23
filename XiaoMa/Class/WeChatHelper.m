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
////    根据服务器端编码确定是否转码
//    NSStringEncoding enc;
//    //if UTF8编码
//    //enc = NSUTF8StringEncoding;
//    //if GBK编码
//    enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    NSString *urlString = [NSString stringWithFormat:@"%@?plat=ios&order_no=%@&product_name=%@&order_price=%f",
//                           SP_URL,
//                           [TradeNO stringByAddingPercentEscapesUsingEncoding:enc],
//                           [pName stringByAddingPercentEscapesUsingEncoding:enc],
//                           price];
//    
//    //解析服务端返回json数据
//    NSError *error;
//    //加载一个NSURL对象
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
//    //将请求的url数据放到NSData对象中
//    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    
//    if ( response != nil) {
//        
//        NSMutableDictionary *dict = NULL;
//        
//        //IOS5自带解析类NSJSONSerialization从response中解析出数据放到字典中
//        dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableLeaves error:&error];
//        
//        NSLog(@"url:%@",urlString);
//        if(dict != nil){
//            NSMutableString *retcode = [dict objectForKey:@"retcode"];
//            if (retcode.intValue == 0){
//                NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
//                
//                //调起微信支付
//                PayReq * req = [[PayReq alloc] init];
//                req.openID = [dict objectForKey:@"appid"];
//                req.partnerId = [dict objectForKey:@"partnerid"];
//                req.prepayId = [dict objectForKey:@"prepayid"];
//                req.nonceStr = [dict objectForKey:@"noncestr"];
//                req.timeStamp = stamp.intValue;
//                req.package = [dict objectForKey:@"package"];
//                req.sign = [dict objectForKey:@"sign"];
//                [WXApi sendReq:req];
//                
//                DebugLog(@"appid=%@\npartid=%@\nprepayid=%@\nnoncestr=%@\ntimestamp=%ld\npackage=%@\nsign=%@",req.openID,req.partnerId,req.prepayId,req.nonceStr,(long)req.timeStamp,req.package,req.sign );
//            }
//            else
//            {
//                [self.rac_wechatResultSignal sendError:[NSError errorWithDomain:[dict objectForKey:@"retmsg"] code:WechatPayFail userInfo:nil]];
//            }
//        }
//        else
//        {
//            [self.rac_wechatResultSignal sendError:[NSError errorWithDomain:@"服务器返回错误，未获取到json对象" code:WechatPayFail userInfo:nil]];
//        }
//    }
//    else
//    {
//        [self.rac_wechatResultSignal sendError:[NSError errorWithDomain:@"服务器返回错误" code:WechatPayFail userInfo:nil]];
//    }
    //创建支付签名对象
    payRequsestHandler *req = [payRequsestHandler alloc];
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //}}}
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPay_demo];
    
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
