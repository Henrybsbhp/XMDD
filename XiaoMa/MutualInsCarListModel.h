//
//  MutualInsCarListModel.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/14/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MutualInsGroupStatus) {
    /// 未参团 / 参团失败
    XMGroupFailed        = 0,
    
    /// 团长无车
    XMGroupWithNoCar     = -1,
    
    /// 资料代完善
    XMDataImcompleteV1   = 1,
    
    /// 资料代完善
    XMDataImcompleteV2   = 2,
    
    /// 审核中
    XMInReview           = 3,
    
    /// 待支付
    XMWaitingForPay      = 5,
    
    /// 支付成功
    XMPaySuccessed       = 6,
    
    /// 互助中
    XMInMutual           = 7,
    
    /// 保障中
    XMInEnsure           = 8,
    
    /// 已过期
    XMOverdue            = 10,
    
    /// 审核失败
    XMReviewFailed       = 20
};


@interface MutualInsCarListModel : NSObject

/// 车型 Logo
@property (nonatomic, copy) NSString *brandLogo;

/// 车牌
@property (nonatomic, copy) NSString *licenseNum;

/// 提示文案
@property (nonatomic, copy) NSString *tip;

/// 车在互助团中的状态
@property (nonatomic) MutualInsGroupStatus status;

/// 状态描述文案
@property (nonatomic, copy) NSString *statusDesc;

/// 入团优惠文案信息列表
@property (nonatomic, copy) NSDictionary *couponList;

/// 团员人数
@property (nonatomic, strong) NSNumber *numberCnt;

/// 订单记录 ID
@property (nonatomic, strong) NSNumber *contractID;

/// 其他信息
@property (nonatomic, copy) NSArray *extendInfo;

/// 团名子
@property (nonatomic, copy) NSString *groupName;

/// 车所在团 ID
@property (nonatomic, strong) NSNumber *groupID;

/// 团员记录 ID
@property (nonatomic, strong) NSNumber *memberID;

/// 用户车辆 ID
@property (nonatomic, strong) NSNumber *userCarID;


+ (instancetype)carlistWithJSONResponse:(NSDictionary *)rsp;

@end
