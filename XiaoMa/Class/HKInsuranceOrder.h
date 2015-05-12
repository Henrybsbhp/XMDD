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
@property (nonatomic, assign) NSInteger instype;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) HKInsurance *policy;
@property (nonatomic, strong) NSString *validperiod;
@property (nonatomic, assign) PaymentChannelType paychannel;
///最后更新时间
@property (nonatomic, strong) NSDate *lstupdatetime;
///保单快递单号
@property (nonatomic, strong) NSString *insdeliveryno;
///保单快递公司
@property (nonatomic, strong) NSString *insdeliverycomp;

+ (instancetype)orderWithJSONResponse:(NSDictionary *)rsp;
- (NSString *)paymentForCurrentChannel;
- (NSString *)descForCurrentInstype;
- (NSString *)descForCurrentStatus;
- (NSString *)generateContent;

@end
