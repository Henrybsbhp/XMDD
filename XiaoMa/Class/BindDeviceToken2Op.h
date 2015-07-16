//
//  BindDeviceToken2Op.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/7/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface BindDeviceToken2Op : BaseOp
@property (nonatomic, copy) NSString *req_deviceToken;
@property (nonatomic, copy) NSString *req_deviceID;
@property (nonatomic, copy) NSString *req_appversion;
@property (nonatomic, copy) NSString *req_osversion;
@property (nonatomic, copy) NSString *req_province;
@property (nonatomic, copy) NSString *req_city;
@property (nonatomic, copy) NSString *req_district;
@end
