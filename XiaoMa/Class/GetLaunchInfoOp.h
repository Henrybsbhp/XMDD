//
//  getLaunchInfoOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKLaunchInfo.h"
#import "HKAddressComponent.h"

@interface GetLaunchInfoOp : BaseOp

@property (nonatomic, strong) NSString *req_province;
@property (nonatomic, strong) NSString *req_city;
@property (nonatomic, strong) NSString *req_district;

@property (nonatomic, strong) NSArray *rsp_infoList;

+ (NSDictionary *)fetchSavedLaunchInfosDict;
+ (NSArray *)parseLuanchInfosWithDict:(NSDictionary *)dict;
+ (HKAddressComponent *)parseAddressWithDict:(NSDictionary *)dict;

@end
