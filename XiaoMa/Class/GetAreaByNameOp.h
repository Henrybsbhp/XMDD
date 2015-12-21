//
//  GetAreaByNameOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/15.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "BaseOp.h"
@class Area;

@interface GetAreaByNameOp : BaseOp
@property (nonatomic, strong) NSString *req_province;
@property (nonatomic, strong) NSString *req_city;
@property (nonatomic, strong) NSString *req_district;

@property (nonatomic, strong) Area *rsp_province;
@property (nonatomic, strong) Area *rsp_city;
@property (nonatomic, strong) Area *rsp_district;
@end
