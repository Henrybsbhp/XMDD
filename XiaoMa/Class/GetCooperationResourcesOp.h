//
//  GetCooperationResourcesOp.h
//  XiaoMa
//
//  Created by jt on 16/3/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "HKCoupon.h"

@interface GetCooperationResourcesOp : BaseOp

@property (nonatomic,strong)NSArray<HKCoupon *>* rsp_couponArray;
@property (nonatomic)CGFloat rsp_maxcouponamt;

@end
