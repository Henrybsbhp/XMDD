//
//  PaymentManager.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    TradeTypeIns = 1,
    TradeTypeCarwash = 2,
    TradeTypeRefuel = 3,
    TradeTypeStagingRefuel = 4,
    TradeTypeGeneral = 5,
    TradeTypeXMIns = 6,
} TradeType;

typedef enum : NSInteger
{
    PaymentPlatformTypeCreditCard = 0,        //信用卡支付
    PaymentPlatformTypeAlipay,                //支付宝支付
    PaymentPlatformTypeWeChat,                //微信支付
    PaymentPlatformTypeUPPay                  //银联支付
}PaymentPlatformType;

@interface PaymentHelper : NSObject

@property (nonatomic, strong) NSString *tradeNumber;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *productDescription;
@property (nonatomic, assign) CGFloat price;
@property (nonatomic, weak) UIViewController *targetVC;
@property (nonatomic, assign) PaymentPlatformType platformType;
/// 交易类型，用于订单状态查询
@property (nonatomic)TradeType tradeType;

- (void)resetForAlipayWithTradeNumber:(NSString *)tn productName:(NSString *)pn productDescription:pd price:(CGFloat)price;
- (void)resetForWeChatWithTradeNumber:(NSString *)tn productName:(NSString *)pn price:(CGFloat)price andTradeType:(TradeType) type;
- (void)resetForUPPayWithTradeNumber:(NSString *)tn targetVC:(UIViewController *)tvc;

- (RACSignal *)rac_startPay;
- (RACSignal *)rac_startPay2;
+ (int)paymentChannelForPlatformType:(PaymentPlatformType)platformType;

@end
