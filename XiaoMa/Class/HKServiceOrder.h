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
@property (nonatomic, strong) JTShop *shop;
@property (nonatomic, strong) NSString *licencenumber;
@property (nonatomic, assign) PaymentChannelType paychannel;
///提交时间
@property (nonatomic, strong) NSDate *txtime;
///评分
@property (nonatomic, assign) float rating;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *ratetime;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;
- (JTShopService *)currentService;
- (NSString *)paymentForCurrentChannel;

@end
