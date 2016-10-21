//
//  HKRescueHistory.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum : NSInteger
{
    HKRescueAnnual = 4,//年检
    HKRescueTrailer = 1,//拖车
    HKRescuePumpPower = 3,//换胎
    HKRescuetire = 2//泵电
}HKRescueType;

// 老的救援状态类型判断
typedef enum : NSInteger
{
    HKRescueStateAlready = 2,//已申请
    HKRescueStateComplete,//已完成
    HKRescueStateCancel,//已取消
    HKRescueStateProcessing//处理中
}HKRescueStateNum;

// 新的救援状态类型判断（以此为准）
typedef enum : NSInteger
{
    HKRescueStatusRequest = 1, // 申请救援
    HKRescueStatusRescueControl = 2, // 救援调度
    HKRescueStatusRescuing = 3, // 救援中
    HKRescueStatusCompleted = 4, // 救援完成
    HKRescueStatusCanceled = 5 // 已取消
} HKRescueStatus;

// 年检协办状态类型判断
typedef enum : NSInteger
{
    HKCommissionWaitForPay = 1, // 待支付
    HKCommissionPaidAlready = 2, // 已支付
    HKCommissionCompleted = 3, // 已完成
    HKCommissionCanceled = 4 // 已取消
} HKCommissionStatus;

typedef enum : NSInteger
{
    HKCommentStatusNo = 0,//未评论
    HKCommentStatusYes = 1//已评论
}HKCommentStatus;

@interface HKRescueHistory : NSObject

@property (nonatomic, assign) HKRescueType  type;//救援类型
@property (nonatomic, assign) HKCommentStatus  commentStatus;//评价状态
@property (nonatomic, assign) HKRescueStateNum  rescueStatus;//救援状态
@property (nonatomic, strong) NSNumber *applyTime;//申请时间
@property (nonatomic, copy) NSString *serviceName;//服务名称
@property (nonatomic, copy) NSString *licenceNumber;//车牌号
@property (nonatomic, strong) NSNumber *applyId;//申请记录id
@property (nonatomic, strong) NSNumber *appointTime;//预约时间
@property (nonatomic, strong) NSNumber *pay; // 支付金额

@end

