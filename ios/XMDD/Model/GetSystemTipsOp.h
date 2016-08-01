//
//  GetSystemTipsOp.h
//  XiaoMa
//
//  Created by jt on 15-4-20.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetSystemTipsOp : BaseOp

@property (nonatomic,copy)NSString * province;
@property (nonatomic,copy)NSString * city;
@property (nonatomic,copy)NSString * district;

@property (nonatomic,copy)NSString * rsp_restriction;
@property (nonatomic,copy)NSString * rsp_temperature;
@property (nonatomic,copy)NSString * rsp_temperaturetip;
@property (nonatomic,copy)NSString * rsp_temperaturepic;

@end
