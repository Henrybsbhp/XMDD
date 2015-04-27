//
//  BuyInsuranceByChannelOp.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "BaseOp.h"
#import "HKInsurace.h"

@interface GetInsuranceByChannelOp : BaseOp
@property (nonatomic, strong) NSString *req_channel;
@property (nonatomic, strong) NSString *req_licencenumber;
@property (nonatomic, strong) NSString *req_idnumber;

@property (nonatomic, strong) NSString *rsp_policyholder;
@property (nonatomic, strong) NSString *rsp_inscomp;
@property (nonatomic, strong) NSString *rsp_idnumber;
@property (nonatomic, strong) NSString *rsp_licencenumber;
@property (nonatomic, strong) NSString *rsp_insperiod;
@property (nonatomic, strong) NSString *rsp_contactnumber;
@property (nonatomic, strong) HKInsurace *rsp_policy;
@property (nonatomic, strong) NSString *rsp_orderid;
@property (nonatomic, strong) NSString *rsp_status;
@property (nonatomic, strong) NSString *rsp_totalpay;
@end
