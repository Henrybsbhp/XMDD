//
//  GetViolationCommissionStateOp.h
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"
#import "ViolationCommissionStateModel.h"

@interface GetViolationCommissionStateOp : BaseOp

@property (nonatomic, strong) NSNumber *recordID;

@property (nonatomic, copy) ViolationCommissionStateModel *vcSateModel;

@end
