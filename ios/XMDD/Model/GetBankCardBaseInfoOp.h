//
//  GetBankCardBaseInfoOp.h
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetBankCardBaseInfoOp : BaseOp

/// 卡号（输入参数）
@property (nonatomic, copy) NSString *cardNo;

/// 发卡行的名字（返回参数）
@property (nonatomic, copy) NSString *issueBank;

/// 卡片类型（返回参数）
@property (nonatomic, copy) NSString *cardType;

/// 银行 Logo（返回参数）
@property (nonatomic, copy) NSString *bankLogo;

@end
