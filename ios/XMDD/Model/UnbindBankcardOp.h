//
//  UnbindBankcardOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface UnbindBankcardOp : BaseOp

@property (nonatomic, strong) NSString *req_vcode;
@property (nonatomic, strong) NSNumber *req_cardid;

@end
