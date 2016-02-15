//
//  CheckUserAwardOp.h
//  XiaoMa
//
//  Created by jt on 15-6-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface CheckUserAwardOp : BaseOp

///距离下次领券日期
@property (nonatomic)NSInteger rsp_leftday;

///礼券金额
@property (nonatomic)NSInteger rsp_amount;

///提示语
@property (nonatomic,copy)NSString * rsp_tip;

///红包已经领取的总数
@property (nonatomic)NSInteger rsp_total;

///红包是否使用
@property (nonatomic)BOOL rsp_isused;

///洗车标识
@property (nonatomic)BOOL rsp_carwashflag;

@end
