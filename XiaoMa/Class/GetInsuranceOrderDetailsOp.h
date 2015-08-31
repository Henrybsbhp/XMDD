
//
//  GetInsuranceOrderDetailsOp.h
//  XiaoMaShop
//  本代码由ckools工具自动生成,工具详情请联系作者@江俊辰
//  Created by Ckools
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKInsuranceOrder.h"

///获取保险订单详情
@interface GetInsuranceOrderDetailsOp : BaseOp

///订单id
@property (nonatomic, strong) NSString* req_orderid;

///保险订单详情
@property (nonatomic, strong) HKInsuranceOrder* rsp_order;


@end
