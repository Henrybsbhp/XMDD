//
//  GetUserCouponByType.h
//  XiaoMa
//
//  Created by jt on 15-5-28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKCoupon.h"

@interface GetUserCouponByTypeOp: BaseOp

@property (nonatomic)CouponType type;

///优惠劵列表
@property (nonatomic,strong)NSArray *rsp_couponsArray;

@end
