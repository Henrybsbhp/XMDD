//
//  GetInsuranceOrderListOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKInsuranceOrder.h"

@interface GetInsuranceOrderListOp : BaseOp

@property (nonatomic, strong) NSArray *rsp_orders;

@end
