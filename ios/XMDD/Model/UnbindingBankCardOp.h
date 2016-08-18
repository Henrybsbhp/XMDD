//
//  UnbindingBankCardOp.h
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface UnbindingBankCardOp : BaseOp

/// token 记录 ID（输入参数）
@property (nonatomic, copy) NSString *tokenID;

@end
