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
    CouponTypeCarWash,//1分钱洗车
    CouponTypeCash,//现金抵扣
    CouponTypeAgency,//免费年检代办
    CouponTypeInsurance,//保险代金券
    CouponTypeRescue//免费道路救援
} CouponType;

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

///优惠券描述
@property (nonatomic,copy)NSString * couponDescription;

///是否已使用
@property (nonatomic)BOOL used;

///是否有效
@property (nonatomic)BOOL valid;

///有效期开始
@property (nonatomic,strong)NSDate *validsince;

///有效期结束
@property (nonatomic,strong)NSDate *validthrough;

///优惠券类型
@property (nonatomic)CouponType conponType;

+ (instancetype)couponWithJSONResponse:(NSDictionary *)rsp;


@end
