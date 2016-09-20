//
//  OutlayCalculateWithFrameNumOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/8/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"
#import "PremiumModel.h"

@interface OutlayCalculateWithFrameNumOp : BaseOp

/// 车架号（输入参数）
@property (nonatomic, copy) NSString *frameNo;

/// 车的ID,如果是有爱车的则查询成功后更新车架号信息。
@property (strong, nonatomic) NSNumber *carID;

/// 设备指纹
@property (strong, nonatomic) NSString *blackBox;

/// 返回信息
@property (strong, nonatomic) PremiumModel *model;

@property (strong, nonatomic)NSDictionary * rspDict;

@end
