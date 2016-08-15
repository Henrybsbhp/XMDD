//
//  PaymentManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayInfoModel.h"

typedef enum : NSUInteger {
    TradeTypeIns = 1,
    TradeTypeCarwash = 2,
    TradeTypeRefuel = 3,
    TradeTypeStagingRefuel = 4,
    TradeTypeGeneral = 5,
    TradeTypeXMIns = 6,
    TradeTypeViolation = 7,
} TradeType;

typedef enum : NSInteger
{
    PaymentPlatformTypeCreditCard = 0,        //信用卡支付
    PaymentPlatformTypeAlipay,                //支付宝支付
    PaymentPlatformTypeWeChat,                //微信支付
    PaymentPlatformTypeUPPay,                  //银联支付
    PaymentPlatformTypeApplePay               // Apple Pay 支付
}PaymentPlatformType;

@interface PaymentHelper : NSObject

/// 订单号
@property (nonatomic, strong) NSString *tradeNumber;
///支付宝支付信息
@property (nonatomic, strong) NSString * alipayInfo;
///微信支付信息
@property (nonatomic, strong) WechatPayInfo * wechatPayInfo;
@property (nonatomic, weak) UIViewController *targetVC;
/// 支付平台
@property (nonatomic, assign) PaymentPlatformType platformType;
/// 交易类型，用于订单状态查询
@property (nonatomic)TradeType tradeType;

@property (nonatomic ,copy)NSString * uppayCouponInfo;

- (void)resetForAlipayWithTradeNumber:(NSString *)tn alipayInfo:(NSString *)alipayInfo;
- (void)resetForWeChatWithTradeNumber:(NSString *)tn andPayInfoModel:(WechatPayInfo *)wechatPayInfo andTradeType:(TradeType)type;
- (void)resetForUPPayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc;
- (void)resetForUPApplePayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc;

- (RACSignal *)rac_startPay;
- (RACSignal *)rac_startPay2;
+ (int)paymentChannelForPlatformType:(PaymentPlatformType)platformType;

@end
