//
//  CheckoutUnioncardQuickpayOp.h
//  XMDD
//
//  Created by RockyYe on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface CheckoutUnioncardQuickpayOp : BaseOp

@property (strong, nonatomic) NSString *req_tokenid;
@property (strong, nonatomic) NSString *req_tradeno;
@property (strong, nonatomic) NSString *req_vcode;

@end
