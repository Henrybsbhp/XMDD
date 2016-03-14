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
} GroupBtnStatus;

@interface HKMutualGroup : NSObject

/// 团名称
@property (nonatomic,copy)NSString * groupName;
/// 按钮状态
@property (nonatomic)GroupBtnStatus btnStatus;
/// 车牌号
@property (nonatomic,copy)NSString * licenseNumber;
/// 团id
@property (nonatomic,copy)NSString * groupId;
/// 自己在团中的团员id
@property (nonatomic,copy)NSString * memberId;
/// 状态描述
@property (nonatomic,copy)NSString * statusDesc;

@end
