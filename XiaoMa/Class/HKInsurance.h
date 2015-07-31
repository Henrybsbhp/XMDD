//
//  HKInsurace.h
//  XiaoMa
//
//  Created by jt on 15-4-21.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <Foundation/Foundation.h>



/// 险种
@interface SubInsurance : NSObject

///险种名称
@property (nonatomic,copy)NSString * coveragerName;

///险种金额
@property (nonatomic,strong) NSString *coveragerValue;

@end




@interface HKInsurance : NSObject

@property (nonatomic,copy)NSString * insuranceName;

/// 保险总价
@property (nonatomic)CGFloat premium;
/// 保险内容<SubInsurace>
@property (nonatomic)NSArray * subInsuranceArray;

+ (instancetype)insuranceWithJSONResponse:(NSDictionary *)rsp;

@end





typedef enum : NSUInteger {
    InsuranceCompulsory = 1101,//交强险
    InsuranceTravelTax = 1102, //车船税
    InsuranceCarDamage,//车辆损失险
    InsuranceThirdPartyLiability,//第三方责任险
    InsuranceCarSeatInsuranceOfDriver,//车上人员座位险（司机）
    InsuranceCarSeatInsuranceOfPassenger,//车上人员座位险（乘客）
    InsuranceWholeCarStolen,//全车盗抢险
    InsuranceSeparateGlassBreakage,//玻璃单独破碎险
    InsuranceSpontaneousLossRisk,//自燃损失险
    InsuranceWaterLoss,//涉水损失险
    InsuranceExcludingDeductible4CarDamage,//车损险不计免赔
    InsuranceExcludingDeductible4ThirdPartyLiability,//第三者责任险不计免赔
    InsuranceExcludingDeductible4CarSeatInsuranceOfDriver,//车上责任险（司机）不计免赔
    InsuranceExcludingDeductible4CarSeatInsuranceOfPassenger,//车上责任险（乘客）不计免赔
    InsuranceExcludingDeductible4WholeCarStolen//全车盗抢险不计免赔
} InsuranceCategory;

typedef enum : NSUInteger {
    InsuranceTypeCompulsion,//强制险
    InsuranceTypeBase,//基本险
    InsuranceTypeAdditional,//附加险
    InsuranceTypeContractualTerms//特约条款
} InsuranceType;

@interface Insurance : SubInsurance

@property (nonatomic)InsuranceCategory insCategory;

/**
 *  是否包含不计免赔
 */
@property (nonatomic)BOOL isContainExcludingDeductible;

/**
 *  相关参数,<NSDictory>
 */
@property (nonatomic)NSArray * params;

- (CGFloat)calcInsurancePrice;

@end