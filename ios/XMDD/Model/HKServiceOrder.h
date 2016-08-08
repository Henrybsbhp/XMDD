//
//  HKServiceOrder.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JTShop.h"
#import "Constants.h"

typedef NS_ENUM(NSInteger, HKServiceOrderStatus) {
    HKServicePayWaiting,  // 待支付
    HKServicePaySuccessed,  // 支付成功
    HKServicePayFailed,  // 支付失败
    HKServiceAskForRefund,  // 申请退款
    HKServiceRefundSuccessed  // 退款成功
};

@interface HKServiceOrder : NSObject

@property (nonatomic, strong) NSNumber *orderid;
@property (nonatomic, strong) NSNumber *serviceid;

/// 订单状态
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *statusDesc;

///服务名称
@property (nonatomic, assign) CGFloat serviceprice;
@property (nonatomic, strong) NSString *servicename;
@property (nonatomic, strong) NSString *orderPic;
@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) NSString *licencenumber;
@property (nonatomic, assign) PaymentChannelType paychannel;
///支付方式
@property (nonatomic, strong) NSString *paydesc;
@property (nonatomic, assign) long long tradetime;
///提交时间
@property (nonatomic, strong) NSDate *txtime;
///评分
@property (nonatomic, assign) float rating;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *ratetime;
///订单支付费用
@property (nonatomic, assign) CGFloat fee;
///洗车返加油券
@property (nonatomic, assign) CGFloat gasCouponAmount;

@property (nonatomic, strong) NSString *nickName;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;
- (JTShopService *)currentService;
- (NSString *)paymentForCurrentChannel;

@end
