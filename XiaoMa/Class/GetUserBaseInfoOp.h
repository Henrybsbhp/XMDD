//
//  GetUserBaseInfoOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/5.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetUserBaseInfoOp : BaseOp
///优惠券数量
@property (nonatomic, assign) NSInteger rsp_vcc;
///免费洗车数量
@property (nonatomic, assign) NSInteger rsp_freewashes;
///银行积分
@property (nonatomic, assign) NSInteger rsp_bankcredit;
///昵称
@property (nonatomic, strong) NSString *rsp_nickName;
///电话
@property (nonatomic, strong) NSString *rsp_phone;
///头像
@property (nonatomic, strong) NSString *rsp_avatar;
///性别(1-男，2-女)
@property (nonatomic, assign) NSInteger rsp_sex;
///生日
@property (nonatomic, strong) NSDate *rsp_birthday;

+ (RACSignal *)rac_fetchUserBaseInfo;

@end
