//
//  GetUserResourcesV2Op.h
//  XiaoMa
//
//  Created by jt on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKCoupon.h"

///查询可用资源V2(获取当前用户所有的银行洗车次数、积分和有效优惠券信息)
@interface GetUserResourcesV2Op : BaseOp

///商户id
@property (nonatomic,strong)NSNumber * shopID;

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

/// 是否洗过车
@property (nonatomic)BOOL rsp_neverCarwashFlag;
/// 是否洗过车(服务器已判断过，当时是否可以参加加油活动)
@property (nonatomic)BOOL rsp_carwashFlag;
///0元活动日标示(0：不是活动日。1：是活动日)
@property (nonatomic)BOOL rsp_activityDayFlag;
///标示是否最近一周领过礼券
@property (nonatomic)BOOL rsp_weeklyCouponGetFlag;

@end
