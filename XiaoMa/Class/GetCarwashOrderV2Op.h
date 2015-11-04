//
//  GetCarwashOrderV2Op.h
//  XiaoMa
//
//  Created by jt on 15/11/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKServiceOrder.h"

@interface GetCarwashOrderV2Op : BaseOp

@property (nonatomic, copy) NSNumber *req_orderid;
@property (nonatomic, strong) HKServiceOrder *rsp_order;

@end
