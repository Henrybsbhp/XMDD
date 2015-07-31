//
//  AuthByVcodeOp.h
//  XiaoMa
//
//  Created by jt on 15-4-13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface AuthByVcodeOp : BaseOp
@property (nonatomic, strong) NSString *req_deviceID;
@property (nonatomic, strong) NSString *req_deviceModel;
@end
