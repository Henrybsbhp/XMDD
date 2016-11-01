//
//  GetRescueOrCommissionDetail.h
//  XMDD
//
//  Created by St.Jimmy on 20/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

// 救援详情状态
typedef enum : NSInteger
{
    HKRescueDetailRequest = 1, // 申请救援
    HKRescueDetailControl = 2, // 救援调度
    HKRescueDetailRescuing = 3, // 救援中
    HKRescueDetailCompleted = 4, // 救援完成
    HKRescueDetailCanceled = 5 // 已取消
} HKRescueDetailStatus;

// 待办详情状态
typedef enum : NSInteger
{
    HKCommissionDetailWaitForPay = 1, // 待支付
    HKCommissionDetailPaidAlready = 2, // 已支付
    HKCommissionDetailCompleted = 3, // 已完成
    HKCommissionDetailCanceled = 4 // 已取消
} HKCommissionDetailStatus;

typedef enum : NSInteger
{
    HKRescueDetailTypeTrailer = 1, // 拖车
    HKRescueDetailTypeTire = 2, // 泵电
    HKRescueDetailTypeExchange = 3, // 换胎
    HKRescueDetailTypeReview = 4 // 年检
} HKRescueDetailType;

@interface GetRescueOrCommissionDetailOp : BaseOp

/// 记录 ID（输入参数）
@property (nonatomic, strong) NSNumber *rsq_applyID;

/// 申请时间（返回参数）
@property (nonatomic, strong) NSNumber *rsp_applyTime;

/// 服务名称（返回参数）
@property (nonatomic, copy) NSString *rsp_serviceName;

/// 车牌号（返回参数）
@property (nonatomic, copy) NSString *rsp_licenseNumber;

/// 救援状态（返回参数）
@property (nonatomic, assign) NSUInteger rsp_rescueStatus;

/// 评价状态（返回参数）
@property (nonatomic, assign) NSUInteger rsp_commentStatus;

/// 申请记录 ID（返回参数）
@property (nonatomic, assign) NSUInteger rsp_applyID;

/// 类型（返回参数）
@property (nonatomic, assign) NSUInteger rsp_type;

/// 预约时间（返回参数）
@property (nonatomic, strong) NSNumber *rsp_appointTime;

/// 支付金额（返回参数）
@property (nonatomic, assign) float rsp_pay;

@end
