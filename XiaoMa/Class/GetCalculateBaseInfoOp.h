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

@end
