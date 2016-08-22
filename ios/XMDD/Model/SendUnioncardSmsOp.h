//
//  SendUnioncardSmsOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface SendUnioncardSmsOp : BaseOp

@property (strong, nonatomic) NSString *req_tokenid;
@property (strong, nonatomic) NSString *req_tradeno;

@end
