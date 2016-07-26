//
//  GetGroupPasswordOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetGroupPasswordOp : BaseOp

@property (nonatomic, strong) NSNumber * req_groupId;

@property (nonatomic, copy) NSString * rsp_groupCipher;

@property (nonatomic, copy) NSString * rsp_wordForShare;

@property (nonatomic, assign) NSInteger rsp_groupType;

@end
