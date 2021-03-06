//
//  CouponModel.h
//  XiaoMa
//
//  Created by jt on 15/8/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "Constants.h"


@interface CouponModel : BaseOp

///洗车次数
@property (nonatomic, assign)NSInteger abcCarwashesCount;
///积分
@property (nonatomic, assign)NSInteger abcIntegral;
///// 可用洗车券,洗车券 = 普通洗车券 + 浙商
//@property (nonatomic, strong)NSArray * validCarwashCouponArray;
///// 可用现金券
//@property (nonatomic, strong)NSArray * validCashCouponArray;
/// 可用保险代金券
@property (nonatomic, strong)NSArray * validInsuranceCouponArray;
/// 所有优惠劵
@property (nonatomic, strong)NSArray * carwashArray;

- (RACSignal *)rac_getVaildResource:(ShopServiceType)type andShopId:(NSNumber *)shopid;

- (RACSignal *)rac_getVaildInsuranceCoupon:(NSNumber *)orderid;

@end
