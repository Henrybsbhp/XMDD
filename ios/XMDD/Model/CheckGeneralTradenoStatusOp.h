//
//  CheckGeneralTradenoStatusOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface CheckGeneralTradenoStatusOp : BaseOp

@property (strong, nonatomic) NSString *req_tradeno;
@property (strong, nonatomic) NSString *rsp_status;

@end
