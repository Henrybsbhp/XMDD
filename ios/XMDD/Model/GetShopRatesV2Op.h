//
//  GetShopRatesV2Op.h
//  XMDD
//
//  Created by jiangjunchen on 16/8/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "BaseOp.h"

@interface GetShopRatesV2Op : BaseOp

///商户ID
@property (nonatomic, strong) NSNumber *req_shopid;

/// 分页数
@property (nonatomic, assign) NSInteger req_pageno;
/// 服务类型集合，多个服务以逗号隔开
@property (nonatomic, strong) NSString *req_serviceTypes;

/// 洗车评价总数
@property (nonatomic, assign) NSInteger rsp_carwashTotalNumber;
/// 保养评价总数
@property (nonatomic, assign) NSInteger rsp_maintenanceTotalNumber;
/// 美容评价总数
@property (nonatomic, assign) NSInteger rsp_beautyTotalNumber;
/// 洗车评价列表
@property (nonatomic,strong)NSArray * rsp_carwashCommentArray;
/// 保养评论列表
@property (nonatomic,strong)NSArray * rsp_maintenanceCommentArray;
/// 美容评论列表
@property (nonatomic,strong)NSArray * rsp_beautyCommentArray;

- (NSArray *)commentArrayForServiceType:(ShopServiceType)serviceType;

@end
