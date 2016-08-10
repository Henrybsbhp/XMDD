//
//  ApplyViolationCommissionOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface ApplyViolationCommissionOp : BaseOp

@property (strong, nonatomic) NSNumber *req_usercarid;
@property (strong, nonatomic) NSString *req_licencenumber;
@property (strong, nonatomic) NSString *req_dates; //多条记录同时申请，@分隔




@end
