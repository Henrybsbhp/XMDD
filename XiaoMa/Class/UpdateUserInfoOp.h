//
//  UpdateUserInfoOp.h
//  XiaoMa
//
//  Created by jt on 15-5-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface UpdateUserInfoOp : BaseOp

@property (nonatomic,copy)NSString * nickname;

@property (nonatomic,copy)NSString * avatarUrl;

@property (nonatomic)NSInteger sex;

@property (nonatomic,strong)NSDate * birthday;

@end
