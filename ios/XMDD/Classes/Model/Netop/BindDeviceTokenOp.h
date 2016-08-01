//
//  BindDeviceToken.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface BindDeviceTokenOp : BaseOp
@property (nonatomic, copy) NSString *req_deviceToken;
@property (nonatomic, copy) NSString *req_deviceID;
@property (nonatomic, copy) NSString *req_appversion;
@property (nonatomic, copy) NSString *req_osversion;

@end
