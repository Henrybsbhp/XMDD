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
@property (nonatomic,copy)NSString * phone;

///会话令牌
@property (nonatomic,copy)NSString * token;

///会话令牌
@property (nonatomic,copy)NSString * type;

@end
