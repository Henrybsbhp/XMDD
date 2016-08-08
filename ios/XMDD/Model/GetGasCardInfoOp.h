//
//  GetGasCardInfoOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 7/21/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetGasCardInfoOp : BaseOp

/// 油卡卡号（输入参数）
@property (nonatomic, copy) NSString *gasCard;

/// 油卡类型（输入参数）  1: 中石化（默认） 2: 中石油
@property (nonatomic, strong) NSNumber *cardType;


/// 用户名称（返回参数）
@property (nonatomic, copy) NSString *username;

@end
