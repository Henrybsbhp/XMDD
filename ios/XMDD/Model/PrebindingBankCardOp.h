//
//  PrebindingBankCardOp.h
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface PrebindingBankCardOp : BaseOp

/// 卡号（输入参数）
@property (nonatomic, copy) NSString *cardNo;
/// 交易流水号（输入参数）
@property (nonatomic, copy) NSString *tradeNo;

/// 绑定银行卡 URL（返回参数）
@property (nonatomic, copy) NSString *bindURL;
@end
