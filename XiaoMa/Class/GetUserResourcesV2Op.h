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

/// 可用洗车券,洗车券 = 普通洗车券 + 浙商
@property (nonatomic, strong)NSArray * validCarwashCouponArray;
/// 可用现金券
@property (nonatomic, strong)NSArray * validCashCouponArray;
/// 可用保险代金券
@property (nonatomic, strong)NSArray * validInsuranceCouponArray;

@end
