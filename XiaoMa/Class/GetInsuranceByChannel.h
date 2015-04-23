//
//  GetInsuranceByChannel.h
//  XiaoMa
//
//  Created by jt on 15-4-22.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKInsurance.h"

@interface GetInsuranceByChannel : BaseOp

///渠道号
@property (nonatomic,copy)NSString * channel;

///车牌
@property (nonatomic,copy)NSString * licencenumber;

///身份证号
@property (nonatomic,copy)NSString * idnumber;

///被保险人姓名
@property (nonatomic,copy)NSString * rsp_policyholder;

///保险公司
@property (nonatomic,copy)NSString * rsp_inscomp;

///身份证号
@property (nonatomic,copy)NSString * rsp_idnumber;

///车牌
@property (nonatomic,copy)NSString * rsp_licencenumber;

///有效时间
@property (nonatomic,copy)NSString * rsp_insperiod;

///业务员号码
@property (nonatomic,copy)NSString * rsp_contactnumber;

///保险方案
@property (nonatomic,strong)HKInsurance * rsp_policy;

///保单ID
@property (nonatomic,copy)NSString * rsp_orderid;

///订单状态
@property (nonatomic)NSInteger rsp_status;

///保费总额
@property (nonatomic)CGFloat rsp_totalpay;

@end
