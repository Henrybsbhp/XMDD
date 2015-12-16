//
//  PayForGasViewController.h
//  XiaoMa
//
//  Created by jt on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GasCard.h"
#import "GasNormalVM.h"

@interface PayForGasViewController : UIViewController

@property (nonatomic,copy)NSString * payTitle;
@property (nonatomic,copy)NSString * paySubTitle;

@property (nonatomic,strong)GasNormalVM * model;

/// 充值金额
@property (nonatomic)NSInteger rechargeAmount;

@end
