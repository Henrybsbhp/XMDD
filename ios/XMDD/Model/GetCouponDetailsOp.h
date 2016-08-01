//
//  GetCouponDetailsOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/9/14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKCoupon.h"

@interface GetCouponDetailsOp : BaseOp

///优惠券id
@property (nonatomic, assign) NSNumber * req_cid;

///优惠劵详情
@property (nonatomic, strong)HKCoupon * rsp_couponDetails;

@end
