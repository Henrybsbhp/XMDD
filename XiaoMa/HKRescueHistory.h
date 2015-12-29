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
    HKRescueAnnual = 0,//年检
    HKRescueTrailer,//拖车
    HKRescuePumpPower,//换胎
    HKRescuetire//泵电
}HKRescueType;


typedef enum : NSInteger
{
    HKRescueStateAlready = 2,//已申请
    HKRescueStateComplete,//已完成
    HKRescueStateCancel,//已取消
    HKRescueStateprocessing//处理中
}HKRescueStateNum;

typedef enum : NSInteger
{
    HKCommentStatusNo = 0,//未评论
    HKCommentStatusYes//已评论
}HKCommentStatus;

@interface HKRescueHistory : NSObject

@property (nonatomic, assign) HKRescueType  type;//救援类型
@property (nonatomic, assign) HKCommentStatus  commentStatus;//评价状态
@property (nonatomic, assign) HKRescueStateNum  rescueStatus;//救援状态
@property (nonatomic, strong) NSDate *applyTime;//申请时间
@property (nonatomic, copy) NSString *serviceName;//服务名称
@property (nonatomic, copy) NSString *licenceNumber;//车牌号
@property (nonatomic, strong) NSNumber *applyId;//申请记录id
@property (nonatomic, strong) NSNumber *appointTime;//预约时间

@end

