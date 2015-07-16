//
//  GetCarwashOrderOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKServiceOrder.h"

@interface GetCarwashOrderOp : BaseOp

@property (nonatomic, copy) NSNumber *req_orderid;
@property (nonatomic, strong) HKServiceOrder *rsp_order;

@end
