//
//  GetCarwashOrderListV2Op.h
//  XiaoMa
//
//  Created by jt on 15/11/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKServiceOrder.h"

@interface GetCarwashOrderListV2Op : BaseOp

@property (nonatomic, assign) long long req_tradetime;
@property (nonatomic, strong) NSArray *rsp_orders;

@end
