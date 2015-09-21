
//
//  InsuranceAppointmentOp.h
//  XiaoMaShop
//  本代码由ckools工具自动生成,工具详情请联系作者@江俊辰
//  Created by Ckools
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

///保险预约购买
@interface InsuranceAppointmentOp : BaseOp

///车牌号
@property (nonatomic, strong) NSString* req_licencenumber;
///行驶城市
@property (nonatomic, strong) NSString* req_city;
///车辆有没有上牌
@property (nonatomic, assign) NSInteger req_register;
///购买价格
@property (nonatomic, assign) NSString *req_purchaseprice;
///提车时间
@property (nonatomic, strong) NSDate* req_purchasedate;
///客户电话
@property (nonatomic, strong) NSString* req_phone;
///身份证号
@property (nonatomic, strong) NSString* req_idcard;
///身份证正面
@property (nonatomic, strong) NSString* req_idpic;
///行驶证正面
@property (nonatomic, strong) NSString* req_driverpic;
///购买车险列表
@property (nonatomic, strong) NSString* req_inslist;

@end
