//
//  GetTokenOp.h
//  XiaoMa
//
//  Created by jt on 15-4-13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetTokenOp : BaseOp

///手机号码
@property (nonatomic,copy)NSString *req_phone;
@property (nonatomic, strong) NSString *rsp_expires;
@property (nonatomic, strong) NSString *rsp_token;

@end
