//
//  CreateGroupOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 3/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface CreateGroupOp : BaseOp

// 团名字
@property (nonatomic, copy) NSString *req_name;

/**
 *  暗号
 */
@property (nonatomic, copy) NSString *rsp_cipher;

/**
 *  团ID
 */
@property (nonatomic, strong) NSNumber *rsp_groupid;


@end
