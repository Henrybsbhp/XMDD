//
//  InsuranceOrderPayOp.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/28.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PayInfoModel.h"

@interface InsuranceOrderPayOp : BaseOp

///支付方式
@property (nonatomic, assign) PaymentChannelType req_paychannel;
///保险订单id
@property (nonatomic, assign) NSNumber * req_orderid;
///用户优惠券id
@property (nonatomic, assign) NSNumber * req_cid;
///是否使用优惠活动
@property (nonatomic, assign) NSInteger req_type;

//实付金额
@property (nonatomic, assign) CGFloat rsp_total;
//交易号
@property (nonatomic, strong) NSString * rsp_tradeno;
///推送地址
@property (nonatomic,copy) NSString * rsp_notifyUrlStr;

///支付信息
@property (nonatomic,strong)PayInfoModel * rsp_payInfoModel;

@end
