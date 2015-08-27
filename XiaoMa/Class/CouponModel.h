//
//  CouponModel.h
//  XiaoMa
//
//  Created by jt on 15/8/20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface CouponModel : BaseOp

///洗车次数
@property (nonatomic, assign)NSInteger abcCarwashesCount;
///积分
@property (nonatomic, assign)NSInteger abcIntegral;
/// 可用洗车券
@property (nonatomic, strong)NSArray * validCarwashCouponArray;
/// 可用现金券
@property (nonatomic, strong)NSArray * validCashCouponArray;
/// 所有优惠劵
@property (nonatomic, strong)NSArray * carwashArray;
/// 可用浙商银行信用卡
@property (nonatomic, strong)NSArray * validCZBankCreditCard;

- (RACSignal *)rac_getVaildResource;

@end
