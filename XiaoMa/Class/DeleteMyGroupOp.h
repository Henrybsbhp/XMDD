//
//  DeleteMyGroupOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface DeleteMyGroupOp : BaseOp

@property (nonatomic, strong)NSNumber * memberId;
@property (nonatomic, strong)NSNumber * groupId;

@end
