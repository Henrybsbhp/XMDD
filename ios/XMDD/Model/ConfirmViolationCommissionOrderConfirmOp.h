//
//  ConfirmViolationCommissionOrderConfirmOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface ConfirmViolationCommissionOrderConfirmOp : BaseOp

@property (strong, nonatomic) NSString *req_recordid;

@property (strong, nonatomic) NSNumber *rsp_money;
@property (strong, nonatomic) NSNumber *rsp_servicefee;
@property (strong, nonatomic) NSNumber *rsp_totalfee;
@property (strong, nonatomic) NSString *rsp_servicename;
@property (strong, nonatomic) NSString *rsp_servicepicurl;

@end
