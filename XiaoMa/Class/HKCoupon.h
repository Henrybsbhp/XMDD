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
    CouponTypeAgency,//免费年检协办
    CouponTypeInsurance,//保险代金券
    CouponTypeRescue,//免费道路救援
    CouponTypeCZBankCarWash = 7// 浙商小马达达洗车券
} CouponType;

typedef enum : NSUInteger {
    CouponNewTypeCarWash = 1, //洗车券
    CouponNewTypeInsurance, //保险券
    CouponNewTypeOthers //其他券
} CouponNewType;

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
