//
//  PolicyInfomationVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetInsuranceByChannelOp.h"

@interface PolicyInfomationVC : UIViewController
@property (nonatomic, strong) GetInsuranceByChannelOp *insuranceOp;
@property (nonatomic, strong) HKInsurance *policy;
@end
