//
//  GetRescueHostCounts.h
//  XiaoMa
//
//  Created by baiyulin on 15/12/11.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetRescueHostCounts : BaseOp
@property (nonatomic, copy) NSString *licensenumber;

@property (nonatomic, strong) NSNumber *counts;//剩余协办次数
@property (nonatomic, strong) NSNumber *amount;//协办服务价格

@end
