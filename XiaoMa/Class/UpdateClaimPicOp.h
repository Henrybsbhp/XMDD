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
@property (strong, nonatomic) NSString *req_localepic;
@property (strong, nonatomic) NSString *req_carlosspic;
@property (strong, nonatomic) NSString *req_carinfopic;
@property (strong, nonatomic) NSString *req_idphotopic;

@end
