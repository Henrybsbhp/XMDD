//
//  GetRescueHostCountsOp.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetRescueHostCountsOp : BaseOp
@property (nonatomic, copy)   NSString          *   licenseNumber;//车牌
@property (nonatomic, strong) NSNumber          *   counts;//剩余次数
@end
