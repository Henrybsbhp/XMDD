//
//  ViolationCommissionStateModel.h
//  XMDD
//
//  Created by St.Jimmy on 8/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, XMViolationCommissionStatus) {
    XMVCommissionWaiting = 0,  // 等待受理
    XMVCommissionPayWaiting = 1,  // 待支付
    XMVCommissionProcessing = 2,  // 代办中
    XMVCommissionComplete = 3,  // 代办完成
    XMVCommissionFailed = 4,  // 代办失败
    XMVCommissionReviewFailed = 6  // 证件审核失败
};

@interface ViolationCommissionStateModel : NSObject

/// 代办车辆
@property (nonatomic, copy) NSString *licenseNumber;

/// 违章地点
@property (nonatomic, copy) NSString *area;

/// 违章行为
@property (nonatomic, copy) NSString *act;

/// 代办状态
@property (nonatomic, assign) NSInteger status;

/// 提示信息
@property (nonatomic, copy) NSString *tips;

/// 代办订单信息
@property (nonatomic, copy) NSArray *orderInfo;

+ (instancetype)listWithJSONResponse:(NSDictionary *)rsp;

@end
