//
//  InsuranceDetailPlanVC.h
//  XiaoMa
//
//  Created by jt on 15/7/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetInsuranceCalculatorOpV2.h"

@interface InsuranceDetailPlanVC : UIViewController

@property (strong,nonatomic)NSArray * planArray;
@property (nonatomic, strong) GetInsuranceCalculatorOpV2 *calculatorOp;

@end
