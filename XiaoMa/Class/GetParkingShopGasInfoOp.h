//
//  GetParkingShopGasInfoOp.h
//  XiaoMa
//
//  Created by St.Jimmy on 6/29/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetParkingShopGasInfoOp : BaseOp

/// 查询类型（请求参数）
@property (nonatomic, strong) NSNumber *searchType;

/// 经度（请求参数）
@property (nonatomic, strong) NSNumber *longitude;

/// 维度（请求参数）
@property (nonatomic, strong) NSNumber *latitude;

/// 页数（请求参数）
@property (nonatomic, strong) NSNumber *pageNo;

/// 放大倍数（请求参数）
@property (nonatomic, strong) NSNumber *range;

/// 城市区域代码（请求参数）
@property (nonatomic, copy) NSString *cityCode;

/// 商户信息（返回数据）
@property (nonatomic, copy) NSArray *extShops;

@end
