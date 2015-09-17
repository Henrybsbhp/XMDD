//
//  InsuranceOrderVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/30.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HKInsuranceOrder.h"

@interface InsuranceOrderVC : UIViewController

@property (nonatomic, strong) HKInsuranceOrder *order;
@property (nonatomic, strong) NSNumber *orderID;

@end
