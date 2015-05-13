//
//  CheckoutServiceOrderOp.h
//  XiaoMa
//
//  Created by jt on 15-4-18.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface CheckoutServiceOrderOp : BaseOp

///
@property (nonatomic,copy)NSNumber *serviceid;

///车牌
@property (nonatomic,copy)NSString * licencenumber;

///优惠券ID
@property (nonatomic,copy)NSString * cid;

///支付渠道
@property (nonatomic)PaymentChannelType  paychannel;

///订单id
@property (nonatomic,copy)NSString * rsp_orderid;

///价格
@property (nonatomic)CGFloat rsp_price;
@end
