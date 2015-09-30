//
//  CheckoutServiceOrderOp.h
//  XiaoMa
//
//  Created by jt on 15-4-18.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface CheckoutServiceOrderOp : BaseOp

@property (nonatomic,copy)NSNumber *serviceid;

///车牌
@property (nonatomic,copy)NSString * licencenumber;

///车型车系
@property (nonatomic,strong) NSString *carbrand;

///优惠券ID
@property (nonatomic,strong)NSArray * couponArray;

///支付渠道
@property (nonatomic)PaymentChannelType  paychannel;

///经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


///订单id
@property (nonatomic,strong)NSNumber * rsp_orderid;

///价格
@property (nonatomic)CGFloat rsp_price;

///交易id，用于提交给第三方支付平台
@property (nonatomic)NSString * rsp_tradeId;
@end
