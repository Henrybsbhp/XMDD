//
//  GetShopByRangeOp.h
//  XiaoMa
//
//  Created by jt on 15-4-14.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetShopByRangeOp : BaseOp

///精度
@property (nonatomic)double longitude;

///纬度
@property (nonatomic)double latitude;

///查询范围
@property (nonatomic)NSInteger range;

/// 商户过滤码
//@property (nonatomic)

@property (nonatomic,strong)NSArray * rsp_shopArray;

@end
