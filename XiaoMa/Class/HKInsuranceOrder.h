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

typedef enum : NSUInteger {
    DiscountTypeMinus = 1, // 优惠直减
    DiscountTypeDiscount // 优惠打折
} DiscountType;

@interface HKInsuranceOrder : NSObject
@property (nonatomic, strong) NSNumber *orderid;
@property (nonatomic, strong) NSString *policyholder;
// 图片url
@property (nonatomic, strong) NSString *picUrl;
@property (nonatomic, strong) NSString *idcard;
@property (nonatomic, strong) NSString *inscomp;
//车牌号码
@property (nonatomic, strong) NSString *licencenumber;
@property (nonatomic, strong) HKInsurance *policy;
// 保险有效期
@property (nonatomic, strong) NSString *validperiod;
@property (nonatomic, assign) PaymentChannelType paychannel;
//总费用
@property (nonatomic, assign) CGFloat totoalpay;
//邮寄地址
@property (nonatomic, assign) NSString *deliveryaddress;
//订单状态
@property (nonatomic, assign) NSInteger status;
//订单最后更新时间
@property (nonatomic, strong) NSDate *lstupdatetime;
//是否使用活动优惠
@property (nonatomic) BOOL isusedCoupon;
//优惠类型
@property (nonatomic, assign) NSInteger couponType;
//优惠名称
@property (nonatomic, strong) NSString *couponName;
//优惠金额
@property (nonatomic, assign) CGFloat couponMoney;



//保险订单活动
@property (nonatomic, assign)BOOL  iscontainActivity;
//活动名称
@property (nonatomic, copy)NSString * activityName;
//活动标签
@property (nonatomic, copy)NSString * activityTag;
//活动类型
@property (nonatomic)DiscountType activityType;
//活动金额，如果coupontype=2,该字段直接为小于1的小数。总金额直接相乘即可
@property (nonatomic)CGFloat activityAmount;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;
- (NSString *)paymentForCurrentChannel;
- (NSString *)descForCurrentInstype;
- (NSString *)descForCurrentStatus;
- (NSString *)generateContent;

@end
