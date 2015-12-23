//
//  GetCityInfoByNameOp.h
//  XiaoMa
//
//  Created by jt on 15/12/4.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "ViolationCityInfo.h"

@interface GetCityInfoByNameOp : BaseOp

@property (nonatomic,copy)NSString * province;
@property (nonatomic,copy)NSString * city;
@property (nonatomic,copy)NSString * district;

@property (nonatomic,strong)ViolationCityInfo * cityInfo;

@property (nonatomic,strong)NSNumber * rsp_sellerCityId;

@end
