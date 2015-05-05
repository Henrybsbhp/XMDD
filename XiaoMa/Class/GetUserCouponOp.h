//
//  GetUserCouponOp.h
//  XiaoMa
//
//  Created by jt on 15-4-30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetUserCouponOp : BaseOp

///是否已使用
@property (nonatomic)NSInteger used;

///
@property (nonatomic)NSInteger pageno;

///优惠劵列表
@property (nonatomic,strong)NSArray *rsp_couponsArray;

@end
