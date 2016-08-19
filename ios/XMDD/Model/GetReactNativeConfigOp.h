//
//  GetReactNativeConfigOp.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/17.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetReactNativeConfigOp : BaseOp
@property (nonatomic, assign) BOOL req_security;
@property (nonatomic, strong) NSString *req_province;
@property (nonatomic, strong) NSString *req_city;
@property (nonatomic, strong) NSString *req_district;

/// 开启react标志 1：开启。0：否
@property (nonatomic, assign) NSInteger rsp_openflag;
@end
