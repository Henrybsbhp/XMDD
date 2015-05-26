//
//  GetCarwashOrderListOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKServiceOrder.h"

@interface GetCarwashOrderListOp : BaseOp

@property (nonatomic, assign) long long req_tradetime;
@property (nonatomic, strong) NSArray *rsp_orders;

@end
