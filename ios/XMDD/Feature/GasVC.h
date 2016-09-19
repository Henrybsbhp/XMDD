//
//  GasVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "HKTableViewController.h"
#import "GasCard.h"
#import "GasChargePackage.h"

@interface GasVC : HKTableViewController

@property (nonatomic, assign) float rechargeAmount;
@property (nonatomic, strong) GasCard *curGasCard;
@property (nonatomic, strong) GasChargePackage *curChargePkg;
@property (nonatomic, assign) float normalRechargeAmount;
@property (nonatomic, assign) float instalmentRechargeAmount;

- (BOOL)isRechargeForInstalment;
- (BOOL)needInvoice;

@end
