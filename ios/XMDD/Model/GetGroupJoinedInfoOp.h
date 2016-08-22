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

@property (nonatomic, copy) NSDictionary *couponList;

/// 参加互助总人数合计（返回参数）
@property (nonatomic, assign) NSInteger totalMemberCnt;
/// 互助金合计（返回参数）
@property (nonatomic, copy) NSString *totalPoolAmt;
/// 补偿总次数（返回参数）
@property (nonatomic, assign) NSInteger totalClaimCnt;
/// 补偿金额合计（返回参数）
@property (nonatomic, copy) NSString *totalClaimAmt;

/// 显示内测计划按钮（返回参数）
@property (nonatomic) BOOL isShowPlanBtn;

/// 显示内测登记按钮（返回参数）
@property (nonatomic) BOOL isShowRegistBtn;

@end
