//
//  GetMessageOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKMessage.h"

@interface GetMessageOp : BaseOp
@property (nonatomic, assign) long long req_msgtime;
@property (nonatomic, strong) NSArray *rsp_msgs;
@end
