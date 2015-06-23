//
//  GainUserAwardOp.h
//  XiaoMa
//
//  Created by jt on 15-6-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GainUserAwardOp : BaseOp

///礼券金额
@property (nonatomic)NSInteger rsp_amount;

///提示语
@property (nonatomic,copy)NSString * rsp_tip;

@end
