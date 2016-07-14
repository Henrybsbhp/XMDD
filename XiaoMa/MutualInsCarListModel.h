//
//  MutualInsCarListModel.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/14/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MutualInsCarListModel : NSObject

/// 车型 Logo
@property (nonatomic, copy) NSString *brandLogo;

/// 车牌
@property (nonatomic, copy) NSString *licenseNum;

/// 提示文案
@property (nonatomic, copy) NSString *tip;

/// 车在互助团中的状态
@property (nonatomic, strong) NSNumber *status;

/// 状态描述文案
@property (nonatomic, copy) NSString *statusDesc;

/// 入团优惠文案信息列表
@property (nonatomic, copy) NSDictionary *couponList;

/// 团员人数
@property (nonatomic, strong) NSNumber *numberCnt;

/// 订单记录 ID
@property (nonatomic, strong) NSNumber *contractID;

/// 互助开始日期
@property (nonatomic, copy) NSString *insStartTime;

/// 互助结束日期
@property (nonatomic, copy) NSString *insEndTime;

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
