//
//  CalculateCooperationFreePremiumOp.h
//  XMDD
//
//  Created by RockyYe on 16/9/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "PremiumModel.h"

@interface CalculateCooperationFreePremiumOp : BaseOp

@property (strong, nonatomic) NSString *req_frameno;

@property (strong, nonatomic) NSString *req_blackbox;
/// 是否有出险
@property (strong, nonatomic) NSNumber *req_hasriskrecord;
/// 返回信息
@property (strong, nonatomic) PremiumModel *model;

@end
