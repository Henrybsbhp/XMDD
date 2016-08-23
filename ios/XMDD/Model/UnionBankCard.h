//
//  UnionBankCard.h
//  XMDD
//
//  Created by RockyYe on 16/8/19.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface UnionBankCard : NSObject

@property (strong, nonatomic) NSNumber *cardno;
@property (strong, nonatomic) NSString *issuebank;
@property (strong, nonatomic) NSString *tokenid;
@property (strong, nonatomic) NSString *cardtypename;
@property (strong, nonatomic) NSNumber *cardtype;
@property (strong, nonatomic) NSString *bindphone;
@property (strong, nonatomic) NSString *changephoneurl;
@property (strong, nonatomic) NSString *banklogo;
@property (strong, nonatomic) NSString *banktip;

@end
