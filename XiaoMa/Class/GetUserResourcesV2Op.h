//
//  GetUserResourcesV2Op.h
//  XiaoMa
//
//  Created by jt on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKCoupon.h"

@interface GetUserResourcesV2Op : BaseOp

@property (nonatomic)ShopServiceType shopServiceType;

///优惠劵列表
@property (nonatomic,strong)NSArray * rsp_coupons;
///浙商信用卡列表
@property (nonatomic,strong)NSArray * rsp_czBankCreditCard;
///银行积分
@property (nonatomic)NSInteger rsp_bankIntegral;
///银行免费洗车
@property (nonatomic)NSInteger rsp_freewashes;

@end
