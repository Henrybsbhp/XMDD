//
//  GetBankCardListV2Op.h
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"
#import "MyBankCardListModel.h"

@interface GetBankCardListV2Op : BaseOp

/// 是否获取全部卡信息（0: 不是，1: 是）
@property (nonatomic, strong) NSNumber *cardType;

@property (nonatomic, copy) NSArray *cards;

@end
