//
//  CheckoutServiceOrderV4Op.h
//  XiaoMa
//
//  Created by jt on 15/11/9.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface CheckoutServiceOrderV4Op : BaseOp

@property (nonatomic,strong)NSNumber *serviceid;

///车牌
@property (nonatomic,copy)NSString * licencenumber;

///车型
@property (nonatomic,copy)NSString *carMake;

///车系
@property (nonatomic,copy)NSString *carModel;

///优惠券ID
@property (nonatomic,strong)NSArray * couponArray;

///支付渠道
@property (nonatomic)PaymentChannelType  paychannel;

///经纬度
@property (nonatomic)CLLocationCoordinate2D coordinate;

///银行卡id
@property (nonatomic,strong)NSNumber *bankCardId;

///设备指纹
@property (nonatomic,copy)NSString *blackbox;


///订单id
@property (nonatomic,strong)NSNumber * rsp_orderid;

///价格
@property (nonatomic)CGFloat rsp_price;

///交易id，用于提交给第三方支付平台
@property (nonatomic)NSString * rsp_tradeId;

///洗车返加油券
@property (nonatomic, assign) CGFloat rsp_gasCouponAmount;

@end
