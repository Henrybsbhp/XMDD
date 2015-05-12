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
    CouponTypeCarWash = 1,
    CouponTypeRescue,
    CouponTypeAgency
} CouponType;

@interface HKCoupon : NSObject

///优惠劵Id
@property (nonatomic,strong)NSNumber * couponId;

///优惠券名称
@property (nonatomic,copy)NSString * couponName;

///数额
@property (nonatomic)NSInteger couponAmount;

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
