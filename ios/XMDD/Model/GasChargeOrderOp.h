//
//  GasChargeOrderOp.h
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"
#import "GasChargedOrderModel.h"

@interface GasChargeOrderOp : BaseOp

@property (nonatomic, assign) long long payedTime;

@property (nonatomic, copy) NSArray *gasChargedData;

@end
