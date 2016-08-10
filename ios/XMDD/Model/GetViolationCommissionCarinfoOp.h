//
//  GetViolationCommissionCarinfoOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetViolationCommissionCarinfoOp : BaseOp

@property (strong, nonatomic) NSNumber *req_usercarid;

@property (strong, nonatomic) NSString *rsp_licenseurl;

@property (strong, nonatomic) NSString *rsp_licensecopyurl;

@property (strong, nonatomic) NSNumber *rsp_carid;

@end
