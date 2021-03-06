//
//  HKMutualGroup.h
//  XiaoMa
//
//  Created by jt on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    GroupBtnStatusNone,
    GroupBtnStatusInvite,
    GroupBtnStatusDelete,
    GroupBtnStatusUpdate
} GroupBtnStatus;

@interface HKMutualGroup : NSObject

/// 团名称
@property (nonatomic,copy)NSString * groupName;
/// 按钮状态
@property (nonatomic)GroupBtnStatus btnStatus;
/// 车牌号
@property (nonatomic,copy)NSString * licenseNumber;
/// 团id
@property (nonatomic,strong)NSNumber * groupId;
/// 不同阶段提示语
@property (nonatomic,copy)NSString * tip;
/// 倒计时
@property (nonatomic,strong)NSNumber * leftTime;
/// 倒计时获取到时的时间戳
@property (nonatomic, assign)NSTimeInterval leftTimeTag;
/// 协议有效时段
@property (nonatomic,copy)NSString * contractperiod;
/// 自己在团中的团员id
@property (nonatomic,strong)NSNumber * memberId;
/// 状态描述
@property (nonatomic,copy)NSString * statusDesc;

- (NSString *)identify;

@end

@interface HKMutualCar : NSObject

/// 车型logo
@property (nonatomic, copy)NSString *brandLogo;
/// 车牌
@property (nonatomic, copy)NSString *licenseNum;
/// 互助预估费用
@property (nonatomic, copy)NSString *premiumPrice;
/// 优惠金额
@property (nonatomic, copy)NSString *couponMoney;
/// 爱车记录ID
@property (nonatomic, strong)NSNumber *carId;

@end

