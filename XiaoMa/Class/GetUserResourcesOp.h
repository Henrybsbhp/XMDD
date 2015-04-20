//
//  GetUserResourcesOp.h
//  XiaoMa
//
//  Created by jt on 15-4-15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetUserResourcesOp : BaseOp

///优惠劵列表
@property (nonatomic,strong)NSArray * rsp_coupons;
///银行积分
@property (nonatomic)NSInteger rsp_bankIntegral;
///银行免费洗车
@property (nonatomic)NSInteger rsp_freewashes;

@end
