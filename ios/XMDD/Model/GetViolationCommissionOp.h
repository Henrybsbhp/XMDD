//
//  GetViolationCommissionOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetViolationCommissionOp : BaseOp

@property (strong, nonatomic) NSString *req_licenceNumber;

@property (strong, nonatomic) NSArray *rsp_lists;

@property (strong, nonatomic) NSString *rsp_tip;

@end
