//
//  GetPayStatusOp.h
//  XiaoMa
//
//  Created by RockyYe on 16/4/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetPayStatusOp : BaseOp

/**
 *  交易号
 */
@property (nonatomic, strong) NSString *req_tradeno;

/**
 *  交易类型
 */
@property (nonatomic, strong) NSString *req_tradetype;

/**
 *  支付状态(yes为已支付、no为未支付)
 */
@property (nonatomic) BOOL rsp_status;

@end
