//
//  HKCoupon.h
//  XiaoMa
//
//  Created by jt on 15-4-17.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableDictionary+AddParams.h"

typedef enum : NSUInteger {
    CouponTypeNone = 0,
    CouponTypeCarWash = 1,//1分钱洗车
    CouponTypeCash = 2,//现金抵扣
    CouponTypeAgency = 3,//免费年检协办
    CouponTypeInsurance = 4,//保险代金券
    CouponTypeRescue = 5,//免费道路救援
    CouponTypeCZBankCarWash = 7,// 浙商小马达达洗车券（废弃）
    CouponTypeWithHeartCarwash = 8,// 精洗券
    CouponTypeInsuranceDiscount = 41,//保险折扣券
    CouponTypeGasNormal = 201,// 加油普通券
    CouponTypeGasReduceWithThreshold = 202,// 加油满减券券
    CouponTypeGasDiscount = 203,// 加油折扣券
    CouponTypeGasFqjy1 = 204,//分期加油1
    CouponTypeGasFqjy2 = 205,//分期加油2
    CouponTypeXMHZ = 301,//小马互助
    CouponTypeBeauty = 401, // 美容代金券
    CouponTypeMaintenance = 501, // 保养代金券
    CouponTypeViolation = 601, // 违章代办
} CouponType;

typedef enum : NSUInteger {
    CouponNewTypeCarWash = 1, //洗车券
    CouponNewTypeInsurance, //保险券
    CouponNewTypeOthers, //其他券
    CouponNewTypeGas //加油券
} CouponNewType;
/// 此枚举用于优惠劵页面的segment类型

typedef enum : NSUInteger {
    CouponUse = 1,//已使用
    CouponUnuse//未使用
} CouponUseType;

@interface HKCoupon : NSObject

///优惠劵Id
@property (nonatomic,strong)NSNumber * couponId;

///优惠券名称
@property (nonatomic,copy)NSString * couponName;

///数额
@property (nonatomic)CGFloat couponAmount;

///优惠折扣
@property (nonatomic)CGFloat couponPercent;

/// 使用门槛
@property (nonatomic)CGFloat lowerLimit;

///优惠券描述
@property (nonatomic, copy)NSString * couponDescription;

///是否已使用
@property (nonatomic)BOOL used;

///是否有效
@property (nonatomic)BOOL valid;

///是否可以分享
@property (nonatomic)BOOL isshareble;

///有效期开始
@property (nonatomic,strong)NSDate *validsince;

///有效期结束
@property (nonatomic,strong)NSDate *validthrough;

///优惠券类型
@property (nonatomic)CouponType conponType;

///优惠券颜色
@property (nonatomic, copy)NSString * rgbColor;

///优惠券logo
@property (nonatomic, copy)NSString * logo;

///优惠券子名字
@property (nonatomic, copy)NSString * subname;


///以下为优惠券详情的字段
@property (nonatomic, strong)NSArray * useguide;

+ (instancetype)couponWithJSONResponse:(NSDictionary *)rsp;

+ (instancetype)couponDetailsWithJSONResponse:(NSDictionary *)rsp;

@end
