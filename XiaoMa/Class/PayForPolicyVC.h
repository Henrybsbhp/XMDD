//
//  PolicyPaymentVC.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetInsuranceByChannelOp.h"

@interface PayForPolicyVC : UIViewController

@property (nonatomic, strong, readonly) GetInsuranceByChannelOp *insuranceOp;

- (void)reloadWithInsuranceOp:(GetInsuranceByChannelOp *)op;

@end
