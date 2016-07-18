//
//  GetCooperationGroupOp.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetCooperationGroupOp : BaseOp

@property (strong, nonatomic) NSNumber *req_status;

@property (strong, nonatomic) NSArray *rsp_groupList;
@property (nonatomic)BOOL rsp_isShowdetailflag;

@end
