//
//  GetGroupJoinedInfoOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetGroupJoinedInfoOp : BaseOp

/// 爱车列表，当前用户所有车辆入团信息列表（返回参数）
@property (nonatomic, copy) NSArray *carList;

/// 显示内测计划按钮（返回参数）
@property (nonatomic) BOOL isShowPlanBtn;

/// 显示内测登记按钮（返回参数）
@property (nonatomic) BOOL isShowRegistBtn;

@end
