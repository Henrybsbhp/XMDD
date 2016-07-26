//
//  MutualInsPayResultVC.h
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MutualInsContract.h"

@interface MutualInsPayResultVC : UIViewController

@property (nonatomic)BOOL isFromOrderInfoVC;

/// 优惠券金额。支付的时候有这个金额，从订单进入的时候没这个金额，这个金额被划分到了协议详情的couponmoney中
@property (nonatomic)CGFloat couponMoney;

/// 总计费用，如果支付页面进来，此值有值。 如果是从订单进入，则自己算
@property (nonatomic)CGFloat totalMoney;

@property (nonatomic,strong)MutualInsContract * contract;

@end
