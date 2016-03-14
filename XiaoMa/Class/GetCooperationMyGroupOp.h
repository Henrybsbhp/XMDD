//
//  GetCooperationMyGroupOp.h
//  XiaoMa
//
//  Created by jt on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

/**
 *  获取用户本人已经参与过的团的状态信息
 */
@interface GetCooperationMyGroupOp : BaseOp

@property (nonatomic,strong)NSArray * rsp_groupArray;

@end
