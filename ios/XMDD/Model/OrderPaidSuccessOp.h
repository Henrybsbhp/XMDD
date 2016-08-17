//
//  InsuranceOrderPaidSuccessOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/29.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface OrderPaidSuccessOp : BaseOp
//通知类型 1：保险   2：洗车   3：加油 4:通用 5:小马互助 7:违章查办
@property (nonatomic, assign) NSInteger req_notifytype;
@property (nonatomic, strong) NSString *req_tradeno;
@end
