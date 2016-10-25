//
//  GetCooperationClaimsListV2Op.h
//  XMDD
//
//  Created by RockyYe on 2016/10/25.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetCooperationClaimsListV2Op : BaseOp

/// 有此参数，则查团理赔记录列表。否则，查个人
@property (strong, nonatomic) NSNumber *req_gid;

@property (strong, nonatomic) NSArray *rsp_claimlist;

@end
