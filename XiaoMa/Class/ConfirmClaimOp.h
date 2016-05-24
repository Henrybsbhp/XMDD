//
//  ConfirmClaimOp.h
//  XiaoMa
//
//  Created by RockyYe on 16/3/22.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfirmClaimOp : BaseOp

@property (nonatomic, strong) NSNumber *req_claimid;
@property (nonatomic, strong) NSNumber *req_agreement;
@property (nonatomic, strong) NSString *req_bankcardno;


@end
