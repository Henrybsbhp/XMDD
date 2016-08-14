//
//  GetCityInfoByLicenseNumberOp.h
//  XMDD
//
//  Created by fuqi on 16/8/8.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"
#import "ViolationCityInfo.h"

@interface GetCityInfoByLicenseNumberOp : BaseOp

@property (nonatomic,copy)NSString *  req_lisenceNumber;

@property (nonatomic,strong)ViolationCityInfo * rsp_violationCityInfo;
/// 车架号
@property (nonatomic,copy)NSString * rsp_carframenumber;
/// 发动机号
@property (nonatomic,copy)NSString * rsp_enginenumber;

@end
