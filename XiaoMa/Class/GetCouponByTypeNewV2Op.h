//
//  GetCouponByTypeNewV2Op.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/10/27.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKCoupon.h"

@interface GetCouponByTypeNewV2Op : BaseOp

///优惠券类型
@property (nonatomic, assign) CouponNewType coupontype;

///分页号
@property (nonatomic) NSInteger pageno;

///优惠劵列表
@property (nonatomic,strong)NSArray *rsp_couponsArray;

@end
