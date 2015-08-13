//
//  GetUserCouponOp2.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKCoupon.h"

@interface GetUserCouponV2Op : BaseOp

///是否已使用
@property (nonatomic) NSInteger used;

///分页号
@property (nonatomic) NSInteger pageno;

///优惠劵列表
@property (nonatomic,strong)NSArray *rsp_couponsArray;

@end
