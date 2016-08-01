//
//  BindBankcardOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface BindBankcardOp : BaseOp

@property (nonatomic, strong) NSString *req_bankcardno;
@property (nonatomic, strong) NSString *req_phone;
@property (nonatomic, strong) NSString *req_vcode;

@end
