//
//  UpdateInsuranceOrderOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/24.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"

@interface UpdateInsuranceOrderOp : BaseOp
@property (nonatomic, strong) NSString *req_deliveryaddress;
@property (nonatomic, assign) int req_paychannel;
@property (nonatomic, strong) NSNumber *req_orderid;
@property (nonatomic, strong) NSString *rsp_tradeno;
@property (nonatomic, assign) CGFloat rsp_premium;
@end
