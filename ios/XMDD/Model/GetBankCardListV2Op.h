//
//  GetBankCardListV2Op.h
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"
#import "MyBankCard.h"

@interface GetBankCardListV2Op : BaseOp

/// 是否获取全部卡信息（0： 快捷支付卡。1： 浙商卡10: 全部）
@property (nonatomic) NSInteger req_cardType;

@property (nonatomic, strong) NSArray *rsp_cardArray;

@end
