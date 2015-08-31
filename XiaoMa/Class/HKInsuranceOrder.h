//
//  HKInsuranceOrder.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/5/11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKInsurance.h"
#import "Constants.h"

@interface HKInsuranceOrder : NSObject
@property (nonatomic, strong) NSNumber *orderid;
@property (nonatomic, strong) NSString *policyholder;
@property (nonatomic, strong) NSString *idcard;
@property (nonatomic, strong) NSString *inscomp;
@property (nonatomic, strong) NSString *licencenumber;
@property (nonatomic, strong) HKInsurance *policy;
@property (nonatomic, strong) NSString *validperiod;
@property (nonatomic, assign) PaymentChannelType paychannel;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSDate *ratetime;
@property (nonatomic, assign) NSInteger instype;
///保单快递单号
@property (nonatomic, strong) NSString *insdeliveryno;
///保单快递公司
@property (nonatomic, strong) NSString *insdeliverycomp;
///银行卡快递单号
@property (nonatomic, strong) NSString *carddeliveryno;
///银行卡快递公司
@property (nonatomic, strong) NSString *carddeliverycomp;
//总费用
@property (nonatomic, assign) NSInteger totoalpay;
//邮寄地址
@property (nonatomic, assign) NSString *deliveryaddress;
//订单状态
@property (nonatomic, assign) NSInteger status;
//订单最后更新时间
@property (nonatomic, assign) NSDate *lstupdatetime;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;
- (NSString *)paymentForCurrentChannel;
- (NSString *)descForCurrentInstype;
- (NSString *)descForCurrentStatus;
- (NSString *)generateContent;

@end
