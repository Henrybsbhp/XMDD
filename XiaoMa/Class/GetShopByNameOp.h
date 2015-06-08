//
//  GetShopByNameOp.h
//  XiaoMa
//
//  Created by jt on 15-4-19.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GetShopByNameOp : BaseOp

///商户名称
@property (nonatomic,copy)NSString * shopName;

///精度
@property (nonatomic)double longitude;

///纬度
@property (nonatomic)double latitude;

///分页数
@property (nonatomic)NSInteger pageno;

/// 商户过滤码
//@property (nonatomic)

///排序方式	1-评级降序（默认）
@property (nonatomic)NSInteger orderby;

@property (nonatomic,strong)NSArray * rsp_shopArray;

@end
