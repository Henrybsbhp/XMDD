//
//  GainUserAwardOp.h
//  XiaoMa
//
//  Created by jt on 15-6-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface GainUserAwardOp : BaseOp

@property (nonatomic, copy)NSString *req_province;
@property (nonatomic, copy)NSString *req_city;
@property (nonatomic, copy)NSString *req_district;
@property (nonatomic, copy)NSString *req_blackbox;

///礼券金额
@property (nonatomic)NSInteger rsp_amount;
///礼券id
@property (nonatomic,strong)NSNumber * rsp_couponId;

///提示语
@property (nonatomic,copy)NSString * rsp_tip;

@end
