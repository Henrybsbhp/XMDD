//
//  GasNormalVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 16/2/26.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "GasSubVC.h"
#import "GasChargePackage.h"

@interface GasNormalVC :GasSubVC
@property (nonatomic, strong) GasChargePackage *curChargePkg;
@property (nonatomic, assign) float normalRechargeAmount;
@property (nonatomic, assign) float instalmentRechargeAmount;

- (BOOL)isRechargeForInstalment;
- (BOOL)needInvoice;

@end
