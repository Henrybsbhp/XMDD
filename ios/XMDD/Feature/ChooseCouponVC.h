//
//  ChooseWashCarTicketVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKCoupon.h"

@interface ChooseCouponVC : HKViewController

@property (nonatomic, weak) UIViewController *originVC;

/// 传入的优惠劵列表
@property (nonatomic,strong)NSArray * couponArray;
/// 输出的优惠劵列表
@property (nonatomic,strong)NSMutableArray * selectedCouponArray;
/// 优惠券类型
@property (nonatomic)CouponType type;
/// 优惠限制（大于这个不能选）
@property (nonatomic)CGFloat upperLimit;
/// 个数限制
@property (nonatomic)CGFloat numberLimit;
/// 优惠额度（大于couponLimit，只优惠couponLimit）
@property (nonatomic)CGFloat couponLimit;
/// 金额
@property (nonatomic)CGFloat payAmount;

@property (strong, nonatomic)void(^finishAction)();

@end
