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

typedef enum : NSUInteger {
    InsuranceOrderStatusUnpaid = 2,     //待付款
    InsuranceOrderStatusOuttime = 4,    //已过期
    InsuranceOrderStatusPaid = 7,       //已支付
    InsuranceOrderStatusStopped = 9,    //已停保
    InsuranceOrderStatusComplete = 10,  //保单已出（已完成）
    InsuranceOrderStatusSended = 11,    //保单已寄出
    InsuranceOrderStatusStopping = 20,  //停保审核中
    InsranceOrderStatusClose = 100      //已关闭
}InsuranceOrderStatus;

@interface HKInsuranceOrder : NSObject
@property (nonatomic, strong) NSNumber *orderid;
@property (nonatomic, strong) NSString *policyholder;
// 图片url
@property (nonatomic, strong) NSString *picUrl;
@property (nonatomic, strong) NSString *idcard;
@property (nonatomic, strong) NSString *inscomp;
@property (nonatomic, strong) NSString *serviceName;
//车牌号码
@property (nonatomic, strong) NSString *licencenumber;
@property (nonatomic, strong) HKInsurance *policy;
// 保险有效期
@property (nonatomic, strong) NSString *validperiod;
// 支付方式的类型
@property (nonatomic, assign) PaymentChannelType paychannel;
// 支付方式
@property (nonatomic, strong) NSString *paydesc;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *ratetime;
@property (nonatomic, assign) NSInteger instype;
///保单号
@property (nonatomic, strong) NSString *insordernumber;
///保单快递单号
@property (nonatomic, strong) NSString *insdeliveryno;
///保单快递公司
@property (nonatomic, strong) NSString *insdeliverycomp;
///银行卡快递单号
@property (nonatomic, strong) NSString *carddeliveryno;
///银行卡快递公司
@property (nonatomic, strong) NSString *carddeliverycomp;

//总费用
@property (nonatomic, assign) CGFloat totoalpay;
//实际支付价格
@property (nonatomic, assign) CGFloat fee;
//邮寄地址
@property (nonatomic, assign) NSString *deliveryaddress;
//订单状态
@property (nonatomic, assign) InsuranceOrderStatus status;
//订单的状态描述
@property (nonatomic, strong) NSString *statusDesc;
//订单详情的状态描述
@property (nonatomic, strong) NSString *statusDetailDesc;
//订单最后更新时间
@property (nonatomic, strong) NSDate *lstupdatetime;
////是否使用活动优惠
//@property (nonatomic) BOOL isusedCoupon;
////优惠类型
//@property (nonatomic, assign) NSInteger couponType;
////优惠名称
//@property (nonatomic, strong) NSString *couponName;
////优惠金额
//@property (nonatomic, assign) CGFloat couponMoney;

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
- (NSString *)detailDescForCurrentStatus;
- (NSString *)descForCurrentStatus;
- (NSString *)generateContent;

@end
