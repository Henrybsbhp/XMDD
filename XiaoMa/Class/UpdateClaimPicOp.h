//
//  UpdateClaimPicOp.h
//  XiaoMa
//
//  Created by RockyYe on 16/5/31.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface UpdateClaimPicOp : BaseOp

@property (strong, nonatomic) NSNumber *req_claimid;
@property (strong, nonatomic) NSArray *req_localepic;
@property (strong, nonatomic) NSArray *req_carlosspic;
@property (strong, nonatomic) NSArray *req_carinfopic;
@property (strong, nonatomic) NSArray *req_idphotopic;

@end
