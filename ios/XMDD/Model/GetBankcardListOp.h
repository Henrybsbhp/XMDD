//
//  GetBankcardListOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKBankCard.h"

@interface GetBankcardListOp : BaseOp

///银行卡列表（listof HKBankCard）
@property (nonatomic, strong) NSArray *rsp_bankcards;

@end
