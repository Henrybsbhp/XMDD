//
//  GetInsuranceDiscountOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/31.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKInsurance.h"

@interface GetInsuranceDiscountOp : BaseOp

///险种对应折扣
@property (nonatomic, strong) NSArray * rsp_dicInsurance;

@end
