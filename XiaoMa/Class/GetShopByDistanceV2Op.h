//
//  GetShopByDistanceV2Op.h
//  XiaoMa
//
//  Created by jt on 15/10/19.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetShopByDistanceV2Op : BaseOp

///精度
@property (nonatomic)double longitude;

///纬度
@property (nonatomic)double latitude;

///分页数
@property (nonatomic)NSInteger pageno;

/// 商户过滤码
@property (nonatomic)NSInteger typemask;

@property (nonatomic,strong)NSArray * rsp_shopArray;


@end
