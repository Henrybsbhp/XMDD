//
//  GetViolationCommissionByIdOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetViolationCommissionByIdOp : BaseOp

@property (strong, nonatomic) NSNumber *req_recordid;

@property (strong, nonatomic) NSDictionary *rsp_data;

/**
 *  代办状态 0:等待受理、1:待支付、2:代办中、3:代办完成、4:代办失败、6:证件审核失败
 */
@property (strong, nonatomic) NSNumber *rsp_status;

@end
