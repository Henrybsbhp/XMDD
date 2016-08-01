//
//  OutlayCalculateWithFrameNumOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface OutlayCalculateWithFrameNumOp : BaseOp

/// 车架号（输入参数）
@property (nonatomic, copy) NSString *frameNo;


/// 品牌车系名字（返回参数）
@property (nonatomic, copy) NSString *brandName;

/// 车架号（返回参数）
@property (nonatomic, copy) NSString *carFrameNo;

/// 预估价（返回参数）
@property (nonatomic, copy) NSString *premiumPrice;

/// 服务费（返回参数）
@property (nonatomic, copy) NSString *serviceFee;

/// 互助金（返回参数）
@property (nonatomic, copy) NSString *shareMoney;

/// 备注项（返回参数）
@property (nonatomic, copy) NSString *note;

@end
