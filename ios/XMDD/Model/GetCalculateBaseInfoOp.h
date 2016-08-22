//
//  GetCalculateBaseInfoOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetCalculateBaseInfoOp : BaseOp

/// 保障列表（返回参数）
@property (nonatomic, copy) NSArray *insuranceList;

/// 优惠列表（返回参数）
@property (nonatomic, copy) NSArray *couponList;

/// 活动列表（返回参数）
@property (nonatomic, copy) NSArray *activityList;

/// 参加互助总人数合计（返回参数）
@property (nonatomic, assign) NSInteger totalMemberCnt;

/// 互助金合计（返回参数）
@property (nonatomic, copy) NSString *totalPoolAmt;

/// 补偿总次数（返回参数）
@property (nonatomic, assign) NSInteger totalClaimCnt;

/// 补偿金额合计（返回参数）
@property (nonatomic, copy) NSString *totalClaimAmt;

@end
