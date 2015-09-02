//
//  HKInsuranceOrder.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKInsurance.h"
#import "Constants.h"

@interface HKInsuranceOrder : NSObject
@property (nonatomic, strong) NSNumber *orderid;
@property (nonatomic, strong) NSString *policyholder;
@property (nonatomic, strong) NSString *idcard;
@property (nonatomic, strong) NSString *inscomp;
@property (nonatomic, strong) NSString *licencenumber;
@property (nonatomic, strong) HKInsurance *policy;
@property (nonatomic, strong) NSString *validperiod;
@property (nonatomic, assign) PaymentChannelType paychannel;
//总费用
@property (nonatomic, assign) CGFloat totoalpay;
//订单状态
@property (nonatomic, assign) NSInteger status;
//订单最后更新时间
@property (nonatomic, strong) NSDate *lstupdatetime;
//是否使用活动优惠
@property (nonatomic) BOOL isusedCoupon;
//优惠名称
@property (nonatomic, strong) NSString * activityName;
//优惠类型
@property (nonatomic, assign) NSInteger couponType;
//优惠名称
@property (nonatomic, strong) NSString *couponName;
//优惠金额
@property (nonatomic, assign) CGFloat couponMoney;



+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;
- (NSString *)paymentForCurrentChannel;
- (NSString *)descForCurrentInstype;
- (NSString *)descForCurrentStatus;
- (NSString *)generateContent;

@end
