//
//  GasPayForCZBVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKBankCard.h"
#import "GasCard.h"
#import "GasCZBVM.h"

@interface GasPayForCZBVC : UIViewController

@property (nonatomic, strong) HKBankCard *bankCard;
@property (nonatomic, strong) GasCard *gasCard;
@property (nonatomic, strong) GasCZBVM *model;
@property (nonatomic, assign) NSInteger chargeamt;
@property (nonatomic, weak) UIViewController *originVC;

@end
