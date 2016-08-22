//
//  GetSystemConfigInfoOp.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/15.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetSystemConfigInfoOp : BaseOp
/// 0：返回所有配置信息(默认) 1:保养描述文案
@property (nonatomic, assign) NSInteger req_type;
@property (nonatomic, strong) NSString *req_province;
@property (nonatomic, strong) NSString *req_city;
@property (nonatomic, strong) NSString *req_area;

/// 保养描述文案
@property (nonatomic, strong) NSDictionary *rsp_configInfo;


@end
