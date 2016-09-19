//
//  PremiumModel.h
//  XMDD
//
//  Created by RockyYe on 16/9/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 费用核算模型
@interface PremiumModel : NSObject

/// 品牌车系名字
@property (nonatomic, copy) NSString *brandName;

/// 车架号
@property (nonatomic, copy) NSString *carFrameNo;

/// 预估价
@property (nonatomic, copy) NSString *premiumPrice;

/// 服务费
@property (nonatomic, copy) NSString *serviceFee;

/// 互助金
@property (nonatomic, copy) NSString *shareMoney;

/// 备注项
@property (nonatomic, copy) NSString *note;

@end
