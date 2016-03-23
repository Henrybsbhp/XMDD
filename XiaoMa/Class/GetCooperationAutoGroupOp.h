//
//  GetCooperationAutoGroup.h
//  XiaoMa
//
//  Created by jt on 16/3/13.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetCooperationAutoGroupOp : BaseOp

///key - value 信息
//name		团名
//grouprestrict		入团限制提示
//memberrestrict		团员限制提示
//grouptag		团标签
//membercnt		以参与人数
//lefttime		倒计时
//ingroup		自己是否在团中
//tip		倒计时提示语
//groupid	团ID

@property (nonatomic,copy)NSString * province;
@property (nonatomic,copy)NSString * city;
@property (nonatomic,copy)NSString * district;

@property (nonatomic,strong)NSArray * rsp_autoGroupArray;

@end
