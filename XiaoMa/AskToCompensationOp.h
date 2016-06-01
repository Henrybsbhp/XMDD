//
//  AskToCompensationOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 5/31/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface AskToCompensationOp : BaseOp

/// 赔偿信息列表
@property (nonatomic, copy) NSArray *claimList;

/// 银行卡描述
@property (nonatomic, copy) NSString *bankNoDesc;

@end
