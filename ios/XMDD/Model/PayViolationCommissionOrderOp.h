//
//  PayViolationCommissionOrderOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "PayInfoModel.h"

@interface PayViolationCommissionOrderOp : BaseOp

@property (strong, nonatomic) NSNumber *req_recordid;
@property (strong, nonatomic) NSNumber *req_paychannel;
@property (strong, nonatomic) NSString *req_couponid;

@property (nonatomic) CGFloat rsp_totalfee;
@property (strong, nonatomic) NSString *rsp_tradeno;
@property (strong, nonatomic) PayInfoModel *rsp_payInfoModel;

@end
