//
//  UpdateViolationCommissionCarinfoOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface UpdateViolationCommissionCarinfoOp : BaseOp

@property (strong, nonatomic) NSString *req_licenseurl;

@property (strong, nonatomic) NSString *req_licensecopyurl;

@property (strong, nonatomic) NSNumber *req_carid;

@end
