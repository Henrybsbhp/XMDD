//
//  UserViolationQueryOp.h
//  XiaoMa
//
//  Created by jt on 15/11/30.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import <Foundation/Foundation.h>

@interface UserViolationQueryOp : BaseOp

///城市代码
@property (nonatomic,copy)NSString * city;

///车牌号码
@property (nonatomic,copy)NSString * licencenumber;

///发动机号
@property (nonatomic,copy)NSString * engineno;

///车架号
@property (nonatomic,copy)NSString * classno;

///爱车信息id
@property (nonatomic,strong)NSNumber * cid;

///失败原因
@property (nonatomic,copy)NSString * rsp_reason;

///违章记录数
@property (nonatomic)NSInteger rsp_violationCount;
///总扣分数
@property (nonatomic)NSInteger rsp_violationTotalfen;
///总罚款
@property (nonatomic)NSInteger rsp_violationTotalmoney;
///违章记录
@property (nonatomic,strong)NSArray * rsp_violationArray;
///可代办条数
@property (nonatomic,copy)NSString * rsp_violationAvailableTip;

@end
