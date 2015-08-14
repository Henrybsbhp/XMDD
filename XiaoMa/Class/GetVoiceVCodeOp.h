//
//  GetVoiceVCodeOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetVoiceVCodeOp : BaseOp
///手机号码
@property (nonatomic, strong) NSString *req_phone;
///会话令牌
@property (nonatomic, strong) NSString *req_token;
@end
