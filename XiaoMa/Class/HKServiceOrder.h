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

@interface HKServiceOrder : NSObject

@property (nonatomic, strong) NSNumber *orderid;
@property (nonatomic, strong) NSNumber *serviceid;
///服务名称
@property (nonatomic, strong) NSString *serviceprice;
@property (nonatomic, strong) NSString *servicename;
@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) NSString *licencenumber;
@property (nonatomic, assign) PaymentChannelType paychannel;
@property (nonatomic, assign) long long tradetime;
///提交时间
@property (nonatomic, strong) NSDate *txtime;
///评分
@property (nonatomic, assign) float rating;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *ratetime;
///订单支付费用
@property (nonatomic, assign) CGFloat fee;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;
- (JTShopService *)currentService;
- (NSString *)paymentForCurrentChannel;

@end
