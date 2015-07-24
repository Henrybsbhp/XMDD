//
//  GetVcodeOp.h
//  XiaoMa
//
//  Created by jt on 15-4-13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetVcodeOp : BaseOp

///手机号码
@property (nonatomic,strong) NSString *req_phone;
///会话令牌
@property (nonatomic,strong) NSString *req_token;

@property (nonatomic,assign) NSInteger req_type;

@end
